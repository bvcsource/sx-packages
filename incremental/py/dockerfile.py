import argparse
import dockerfile_syntax as d
import sys
import distinfo

BUILD = 'build'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--with-proxy')
parser.add_argument('--os', required=True)
parser.add_argument('--release', required=True)
parser.add_argument('--product', required=True)
parser.add_argument('--base')
args = parser.parse_args()

try:
    dist = distinfo.distributions[args.os]()
except KeyError:
    print >>sys.stderr, "Unknown distribution: %s" % args.os
    exit(1)

homedir = "/home/%s/" % BUILD
if args.base is not None:
    d.print_from(image=args.base, tag='')
    dist.builddep(homedir, args.product)
    d.print_user('build')
    volsrc = '/usr/src/%s' % args.product
    d.print_volume(volsrc)
    d.print_volume('/home/build/rules/%s' % dist.ruledir())
    d.print_cmd(
        [d.command(["set", "-x"]),
         d.command(["git", "clone", volsrc]),
         d.command(["cd", args.product]),
         d.command(["ls"])] +
        dist.build_commands(args.product)
    )
    exit(0)

if args.with_proxy is not None:
    env_vars = [
        ("http_proxy", args.with_proxy),
        ("https_proxy", args.with_proxy)
    ]
else:
    env_vars = []

d.print_from(image=args.os, tag=args.release)
for (key, val) in env_vars:
    d.print_env(key=key, val=val)
dist.install(dist.minimal_packages() + dist.extra_packages())

d.print_commands(dist.useradd_commands(BUILD))
d.print_workdir(homedir)
d.print_commands([d.command(["chown", "build:build", "/home/build"])])
