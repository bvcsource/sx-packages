import abc
import re
import dockerfile_syntax as d

DISTRIBUTIONS = {
    "debian": ["7", "8"],
    "32bit/debian": ["jessie"],
    "fedora": ["21", "22"],
    "centos": ["6", "7"],
    "ubuntu": ["12.04", "14.04", "15.04"]
}


class Distribution(object):
    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def install_commands(self, packages):
        pass

    @abc.abstractmethod
    def purge_commands(self, packages):
        pass

    @abc.abstractmethod
    def clean_commands(self):
        pass

    @abc.abstractproperty
    def minimal_packages(self):
        return []

    @abc.abstractproperty
    def extra_packages(self):
        return []

    @abc.abstractproperty
    def builddep_packages(self):
        return []

    @abc.abstractproperty
    def builddep_commands(self, product):
        return []

    @abc.abstractproperty
    def ruledir(self):
        return ""

    @abc.abstractproperty
    def rulefile(self, product):
        return ""

    @abc.abstractproperty
    def rulefilter(self):
        return None

    @abc.abstractproperty
    def ruleappend(self):
        return None

    @abc.abstractproperty
    def build_commands(self, product):
        return []

    @abc.abstractproperty
    def useradd_commands(self, username):
        return []

    def install(self, packages):
        d.print_commands(
            self.install_commands(packages) + self.clean_commands()
        )

    def builddep(self, homedir, product):
        packages = self.builddep_packages()
        self.install(packages)
        src = "%s/%s" % (self.ruledir(), self.rulefile(product))
        d.print_copy(src, homedir+src, escape=False)
        d.print_commands(self.builddep_commands(product))
        d.print_commands(self.purge_commands(packages) + self.clean_commands())


class APTBased(Distribution):
    def install_commands(self, packages):
        return [
            d.command(["apt-get", "update"]),
            d.command(["apt-get", "install", "--no-install-recommends", "-y"],
                      sortableargs=packages),
        ]

    def purge_commands(self, packages):
        return [
            d.command(["apt-get", "purge", "-y"], sortableargs=packages),
            d.command(["apt-get", "autoremove", "-y"])
        ]

    def clean_commands(self):
        return [
            d.command(["apt-get", "clean"])
        ]

    def minimal_packages(self):
        return ["build-essential", "devscripts", "fakeroot"]

    def extra_packages(self):
        return ["git"]

    def builddep_packages(self):
        return ["pbuilder", "aptitude"]

    def builddep_commands(self, product):
        return ["/usr/lib/pbuilder/pbuilder-satisfydepends"]

    def ruledir(self):
        return "debian"

    def rulefile(self, product):
        return "control"

    def rulefilter(self):
        return None

    def ruleappend(self):
        return None

    def useradd_commands(self, username):
        return [d.command(["/usr/sbin/useradd", "-u", "2000", "-m", username])]

    def build_commands(self, product):
        return [
            d.command(["cp", "-a", "/home/build/rules/debian", "."]),
            d.command(["debuild", "-j5", "-i", "-us", "-uc", "-b"])
        ]


class YumBased(Distribution):
    def install_commands(self, packages):
        return [
            d.command(["yum", "-v", "-y", "install"], sortableargs=packages),
        ]

    def purge_commands(self, packages):
        return [
            d.command(["yum", "erase", "-y"], sortableargs=packages)
        ]

    def clean_commands(self):
        return [
            d.command(["yum", "clean", "all"])
        ]

    def minimal_packages(self):
        # Fedora packaging policy no longer specifies the build environment,
        # beyond "rpm is there and can process your specfile"
        return ["rpm-build", "coreutils"]

    def extra_packages(self):
        return ["git"]

    def builddep_packages(self):
        return [d.command(["yum-utils"])]

    def builddep_commands(self, product):
        return [d.command(["yum-builddep", "-y", "%s/%s" % (self.ruledir(),self.rulefile(product))], escape=False),
                d.command(["rm", "-rf", "/home/build/rpmbuild"])]

    def ruledir(self):
        return "rpmbuild"

    def rulefile(self, product):
        return "SPECS/%s.spec" % product

    def rulefilter(self):
        return "BuildRequires|^%if|^%else|^%endif"

    def ruleappend(self):
        return [
            "Name: builddep",
            "Version: 0.1",
            "Release: 1",
            "Summary: build-dep",
            "License: GPL-2",
            "%description",
            "."
        ]

    def useradd_commands(self, username):
        return [d.command(["/usr/sbin/useradd", "-u", "2000", "-m", username])]

    def build_commands(self, product):
        return [d.command(["rpmbuild", "-bb", '/home/build/rules/%s/%s' %
                           (self.ruledir(), self.rulefile(product))], escape=False)]

distributions = {
    'debian': APTBased,
    '32bit/debian': APTBased,
    'ubuntu': APTBased,
    'centos': YumBased,
    'fedora': YumBased,
}
