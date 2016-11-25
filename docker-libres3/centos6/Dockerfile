FROM centos:centos6

COPY skylable.repo /etc/yum.repos.d/

# add epel

RUN echo 'deltarpm=0' >> /etc/yum.conf && \
    sed -i 's/^mirrorlist=/#mirrorlist=/' /etc/yum.repos.d/* && \
    sed -i 's/^#baseurl=/baseurl=/' /etc/yum.repos.d/* && \
    sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf;

# Install the minimal build-dependencies + extras for build.sh
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install \
        bash bzip2 coreutils cpio diffutils fedora-release findutils \
        gawk gcc gcc-c++ grep gzip info make patch redhat-rpm-config \
        rpm-build sed shadow-utils tar unzip util-linux which xz \
        http://cdn.skylable.com/packages/ocaml/4.01.0/rpm/epel-6/ocaml-runtime-4.01.0-16.el6.x86_64.rpm \
        http://cdn.skylable.com/packages/ocaml/4.01.0/rpm/epel-6/ocaml-docs-4.01.0-16.el6.x86_64.rpm \
        http://cdn.skylable.com/packages/ocaml/4.01.0/rpm/epel-6/ocaml-compiler-libs-4.01.0-16.el6.x86_64.rpm \
        http://cdn.skylable.com/packages/ocaml/4.01.0/rpm/epel-6/ocaml-4.01.0-16.el6.x86_64.rpm \
        http://cdn.skylable.com/packages/ocaml/4.01.0/rpm/epel-6/ocaml-camlp4-4.01.0-16.el6.x86_64.rpm \
        http://cdn.skylable.com/packages/ocaml/4.01.0/rpm/epel-6/ocaml-camlp4-devel-4.01.0-16.el6.x86_64.rpm \
        skylable-sx git yum-utils && \
    yum clean all
# add build account
RUN /usr/sbin/useradd -u 2000 build

# allow to upload packages to the indians
COPY rpmmacros /home/build/.rpmmacros
COPY *.spec /home/build/
COPY skel/ /home/build/
COPY build.sh /usr/bin/

# fix permissions on build
RUN chown -R build:build /home/build/

# Install the dependencies from .spec
RUN yum-builddep -y /home/build/*.spec && \
    yum erase -y yum-utils && yum clean all && \
    rm -f /home/build/*.spec

USER build
