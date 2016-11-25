FROM fedora:21

COPY skylable.repo /etc/yum.repos.d/

ENV http_proxy http://proxy:3128
ENV https_proxy http://proxy:3128
RUN echo 'deltarpm=0' >> /etc/yum.conf && \
    sed -i 's/^mirrorlist=/#mirrorlist=/' /etc/yum.repos.d/* && \
    sed -i 's/^#baseurl=/baseurl=/' /etc/yum.repos.d/*

# Install the minimal build-dependencies + extras for build.sh:w
RUN yum -y update && \
    yum -y install \
        bash bzip2 coreutils cpio diffutils fedora-release findutils \
        gawk gcc gcc-c++ grep gzip info make patch redhat-rpm-config \
        rpm-build sed shadow-utils tar unzip util-linux which xz \
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
RUN chown -R build.build /home/build/;

RUN yum-builddep -y /home/build/*.spec && \
    yum erase -y yum-utils && yum clean all && \
    rm -f /home/build/*.spec

USER build
