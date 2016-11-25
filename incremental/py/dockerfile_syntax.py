from pipes import quote


def print_from(**kwargs):
    print "FROM {image}:{tag}".format(**kwargs)


def print_env(**kwargs):
    print "ENV {key} {val}".format(**kwargs)


def command(args, sortableargs=[], escape=True):
    if escape:
        args = [quote(arg) for arg in args]
    cmd = " ".join(args)
    extra = " \\\n\t".join(sorted([" "]+sortableargs))
    return cmd + extra


def print_commands(commands):
    print "RUN",
    print " && \\\n    ".join(commands)


def print_copy(src, dest, escape=True):
    if escape:
        src = quote(src)
        dest = quote(dest)
    print "COPY {src} {dest}".format(src=src, dest=dest)


def print_user(user):
    print "USER %s" % user


def print_onbuild():
    print
    print "ONBUILD \\"


def print_cmd(commands):
    print "CMD",
    print " && \\\n    ".join(commands)


def print_volume(vol):
    print "VOLUME [\"%s\"]" % vol

def print_workdir(dir):
    print "WORKDIR %s" % dir
