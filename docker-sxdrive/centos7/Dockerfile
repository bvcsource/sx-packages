FROM centos:centos7


RUN echo 'deltarpm=0' >> /etc/yum.conf && \
    sed -i 's/^mirrorlist=/#mirrorlist=/' /etc/yum.repos.d/* && \
    sed -i 's/^#baseurl=/baseurl=/' /etc/yum.repos.d/* 
ADD skylable.repo /etc/yum.repos.d/

RUN yum clean all && \
	yum -y update && \
	yum -y install bash bzip2 coreutils cpio diffutils fedora-release findutils gawk gcc gcc-c++ grep \ 
	gzip info make patch redhat-rpm-config rpm-build sed shadow-utils tar unzip util-linux which xz \
	openssl-devel yum-utils git wget sudo epel-release 
#skylable-sx 

RUN git clone http://git.skylable.com/sx /tmp/sx && \
	cd /tmp/sx && \
	./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && \
	make -j 8 && \
	make install
ADD sxdrive.spec /home/makerpm/sxdrive.spec
RUN yum-builddep -y /home/makerpm/sxdrive.spec 

# add makerpm account
RUN /usr/sbin/useradd makerpm && \
        usermod -G wheel makerpm && \
        sed -i 's/^%wheel.*$/%wheel ALL = (ALL) NOPASSWD: ALL/' /etc/sudoers

RUN mkdir -p /home/makerpm/rpmbuild/SOURCES
ADD build.sh /usr/bin/

ADD init.sh /usr/bin/
ADD skel/ /root/

# add sources
RUN chown -R makerpm.makerpm /home/makerpm/

