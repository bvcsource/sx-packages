#! /usr/bin/python
import distinfo

REPOURL = "git+ssh://{user}@git.dev.skylable.com/home/git/{product}.git"
PRODUCTS = [("sx", "skylable-sx"), ("libres3", "libres3") ]
#            , "sxdrive"]
# "sxweb", "sxdrive-android"]

import os
import argparse
from dockerfile_syntax import command
from glob import glob
import re
import sys
import errno
import stat

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--with-proxy', metavar='http://PROXY:PORT',
                    help='proxy to use for package installs',
                    default='http://proxy:3128')
parser.add_argument('--with-git-user', default='ro')
args = parser.parse_args()

this = os.path.basename(__file__)


def commands(l):
    return " && ".join(l)


def product_cloneurl(name):
    return REPOURL.format(user=args.with_git_user, product=name)


def mkdir_p(path):
    try:
        os.makedirs(path, 0750)
    except OSError as exc:
        if exc.errno == errno.EEXIST:
            pass
        else:
            raise


def print_shell_header(f):
    print >>f, "\n".join([
        "#!/bin/sh",
        "set -e",
        # make sure it doesn't ask for passwords via the GUI:
        "unset DISPLAY"
    ])

BUILD = "build"


def print_parallel_runner(title, dirname, lst, to_string, printer):
    dirname = "%s/%s" % (BUILD, dirname)
    mkdir_p(dirname)
    screen_cmdfile = "%s/screen_cmds" % dirname
    with open(screen_cmdfile, 'w') as sf:
        cmds = []
        for el in lst:
            elstr = to_string(el)
            fname = "%s/%s.sh" % (dirname, re.sub("[/:]", "_", elstr))
            el_title = "%s %s" % (title, elstr)
            with open(fname, 'w') as f:
                print_shell_header(f)
                printer(f, el)
                os.fchmod(f.fileno(), stat.S_IRWXU)
                print >>f, "/usr/bin/printf \"%s: \\e[32m%s\\033[0m\\n\"" % (el_title, "SUCCESS")
            # setsid needed to make sure it cannot ask for passwords from the terminal
            cmds.append(command(["screen", "-t", el_title, "-L", "setsid", "-w", fname]))
        print >>sf, "\nsplit\nfocus\n".join(cmds)
    with open("%s.sh" % dirname, 'w') as f:
        print_shell_header(f)
        print >>f, "rm -f screenlog.*"
        print >>f, "screen -L -c %s/screen_cmds" % dirname
        print >>f, "tail -n2 screenlog.*"
        os.fchmod(f.fileno(), stat.S_IRWXU)
    print "Wrote %s*" % dirname


def git_clone_fetch(f, (product, _)):
    url = product_cloneurl(product)
    base = os.path.basename(url)
    print >>f, "mkdir -p build/git"
    print >>f, "cd build/git"
    print >>f, command(["test", "-f", "%s/packed-refs" % base]),
    print >>f, "|| (%s)" % (commands([
        command(["rm", "-rf", base]),
        command(["git", "clone", "--bare", url])
    ]))
    print >>f, commands([
        command(["cd", base]),
        command(["git", "fetch", "--all"])
    ])

print_parallel_runner("GIT CLONE/FETCH", "pull-src", PRODUCTS, lambda (x,_): x,git_clone_fetch)


def docker_pull(f, tag):
    print >>f, command(["docker", "pull", tag])


dist_releases = [(dist, release) for dist in distinfo.DISTRIBUTIONS for release in distinfo.DISTRIBUTIONS[dist]]

tags = [dist + ":" + release for (dist, release) in dist_releases]
print_parallel_runner("DOCKER PULL", "pull-docker", tags, lambda x: x, docker_pull)


def docker_names(dist, release, product):
    image_tag_base = re.sub('[^a-z0-9-_.]', '_',
                            '%s:%s' % (dist, release))
    image_tag = 'skylable_%s_%s' % (image_tag_base, product)
    distdir = '%s/docker/%s' % (BUILD, image_tag)
    return '%s/Dockerfile' % distdir


def docker_build_base(f, dist_release):
    dist, release = dist_release
    if args.with_proxy != '':
        proxy_arg = ['--with-proxy=%s' % args.with_proxy]
    else:
        proxy_arg = []
    dockerfile = docker_names(dist, release, BUILD)
    print >>f, command(["mkdir", "-p", os.path.dirname(dockerfile)])
    print >>f, command(["python", "py/dockerfile.py", "--product=", "--os", dist, "--release", release] + proxy_arg),
    print >>f, ">" + dockerfile
    print >>f, command(["echo", "Wrote %s" % dockerfile])
    tag = os.path.basename(os.path.dirname(dockerfile))
    print >>f, command(["docker", "build", "-t", tag, os.path.dirname(dockerfile)])


def dr_to_string((dist, release)):
    return os.path.basename(os.path.dirname(docker_names(dist, release, BUILD)))

mkdir_p("%s/docker" % BUILD)
print_parallel_runner("DOCKER BUILD", "build-base", dist_releases, dr_to_string, docker_build_base)

for (product, rpm_product) in PRODUCTS:
    def docker_build_product(f, dist_release):
        dist, release = dist_release
        dockerfile = docker_names(dist, release, product)
        basefile = docker_names(dist, release, BUILD)
        base = os.path.basename(os.path.dirname(basefile))
        info = distinfo.distributions[dist]()
        rulefile = info.rulefile(rpm_product)
        ruledir = "%s/%s" % (os.path.dirname(dockerfile), info.ruledir() + "/" + os.path.dirname(rulefile)) + "/"
        print >>f, "pwd"
        print >>f, command(["mkdir", "-p", ruledir])
        print >>f, command(["cp", "-v", "rules/%s/%s/%s" % (product, info.ruledir(), rulefile), ruledir], escape=False)
        filter = info.rulefilter()
        if filter is not None:
            print >>f, command(["sed", "-i", "-re", "/" + filter + "/!d"]),
            print >>f, "%s/*" % ruledir
        append = info.ruleappend()
        rfile = "%s/%s/%s" % (os.path.dirname(dockerfile), info.ruledir(), rulefile)
        if append is not None:
            print >>f, command(["echo", "\n".join(append)]),
            print >>f, ">>" + rfile
        if ".spec" in rulefile:
            product_name = rpm_product
        else:
            product_name = product
        # don't change timestamp of file too often or it invalidates the docker cache,
        # which looks at both file attributes and contents
        print >>f, command(["touch", "-t", "01010000", rfile])
        print >>f, command(["python", "py/dockerfile.py", "--base", base, "--product", product_name, "--os", dist, "--release", release]),
        print >>f, ">" + dockerfile
        print >>f, command(["echo", "Wrote %s" % dockerfile])
        tag = os.path.basename(os.path.dirname(dockerfile))
        print >>f, command(["docker", "build", "-t", tag, os.path.dirname(dockerfile)])
    print_parallel_runner("DOCKER BUILD", "build-%s" % product, dist_releases, dr_to_string, docker_build_product)

"""
exit(0)



def generate_docker_build(dist, release, product=BUILD):
    dockerfile, dockerout, variables = docker_names(dist, release, product)
    if product != BUILD:
        parentfile, parentout, _ = docker_names(dist, release, BUILD)
        info = distinfo.distributions[dist]()
        ruledir = "%s/%s" % (os.path.dirname(dockerfile), info.ruledir())
        inputs = [parentout, ruledir]
        variables['base'] = os.path.basename(os.path.dirname(parentfile))
        # TODO: filter so that it contains only build-deps
        ninja.build(ruledir, 'copy_dir', inputs=[
            'rules/%s/%s' % (product, info.ruledir())
        ])
    else:
        inputs = []
    ninja.build(dockerfile, 'generate_dockerfile',
                implicit=glob("py/dockerfile*.py")+['py/distinfo.py'],
                variables=variables)
    ninja.build(dockerout, 'docker_build', inputs + [dockerfile],
                variables=variables)
    return dockerfile, dockerout


for product in [BUILD] + PRODUCTS:
    out = 'build/%s'
    with open(out, 'w') as f:

    # Docker doesn't support symlinks, have to copy
    ninja.rule('copy_dir', description='CP $out',
               command='cp -a $in $out')
    ninja.rule('generate_dockerfile', description='GEN $out',
               command='python py/dockerfile.py --base=$base --product=$product --os=$os --release=$release %s >$out' % proxy_arg
               )
    ninja.rule('docker_build', description='DOCKER BUILD $tag',
               command='docker build -t $tag $dir >$out || mv $out $out.failed')
    ninja.rule('docker_pull', description='DOCKER PULL $tag',
               command='docker pull $tag')
    ninja.rule('docker_run', description="DOCKER RUN $out",
               command='docker run -v $$(pwd)/$builddir/git/$product.git:/usr/src/$product:ro -v $$(pwd)/rules/$product/$ruledir:/home/build/rules/$ruledir:ro $tag >$out || mv $out $out.failed')
    ninja.newline()

    dockerfiles = []
    for product in [BUILD] + PRODUCTS:
        ninja.comment("Docker images for %s" % product)
        outputs = []
        for dist in distinfo.DISTRIBUTIONS:
            info = distinfo.distributions[dist]()
            for release in distinfo.DISTRIBUTIONS[dist]:
                dockerfile, dockerout = generate_docker_build(dist, release, product)
                dockerfiles.append(dockerfile)
                if product != BUILD:
                    tag = os.path.basename(os.path.dirname(dockerfile))
                    build_log = os.path.dirname(dockerfile)+'_run.log'
                    ninja.build(build_log, 'docker_run', dockerout, variables={
                        'tag': tag,
                        'product': product,
                        'ruledir': info.ruledir()
                    })
                    outputs.append(build_log)
        ninja.build('build-%s' % product, 'phony', outputs)
        ninja.newline()

    ninja.build('update-dockerfiles', 'phony', dockerfiles)
    ninja.newline()

    update_images = []
    for dist in distinfo.DISTRIBUTIONS:
        for release in distinfo.DISTRIBUTIONS[dist]:
            tag = '%s:%s' % (dist, release)
            update = 'update-%s' % tag
            ninja.build(update, 'docker_pull', variables={'tag': tag})
            update_images.append(update)

    ninja.build('pull-images', 'phony',  update_images)
    ninja.newline()

    ninja.comment("Product git repositories")
    ninja.pool('git', 1)
    ninja.rule('git_clone', description='GIT CLONE $url', pool='git',
               command='cd $builddir/git && rm -rf $base && DISPLAY= setsid -w git clone --bare $url')
    ninja.rule('git_fetch', description='GIT FETCH $base', pool='git',
               command='cd $builddir/git/$base && DISPLAY= setsid -w git fetch --all')
    for product in PRODUCTS:
        url = product_cloneurl(product)
        base = os.path.basename(url)
        ninja.build('$builddir/git/%s/packed-refs' % base, 'git_clone',
                    variables={'url': url, 'base': base})
#        ninja.build('update-git-%s' % product, 'git_fetch',
#                    '$builddir/git/%s/packed-refs' % base, variables={'base': base})
print('Generated %s' % out)


"""
