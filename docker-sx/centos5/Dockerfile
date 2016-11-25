FROM centos:centos5

ADD init.sh /usr/bin/


ENV http_proxy http://proxy:3128
ENV https_proxy http://proxy:3128
RUN echo 'deltarpm=0' >> /etc/yum.conf && \
    sed -i 's/^mirrorlist=/#mirrorlist=/' /etc/yum.repos.d/* && \
    sed -i 's/^#baseurl=/baseurl=/' /etc/yum.repos.d/* && \
    sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf;

RUN yum clean all

# update
RUN yum -y update; 

# build deps
RUN yum -y install make gcc zlib-devel nss-devel openssl-devel openssh-server \
	buildsys-macros-5-5 rpm-build fedora-packager python-ctypes libidn-devel yum-utils libtool libtool-ltdl-devel \
	ccache \
	s3cmd tcpdump tmux screen wget sudo 

# add epel
RUN wget --no-check-certificate http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm https://fedoraproject.org/static/217521F6.txt && \
       rpm --import ./217521F6.txt && \
       yum -y install ./epel-release-5-4.noarch.rpm  && \
       yum clean all

RUN yum -y install /etc/rpm/macros.dist git

# add makerpm account and install git
RUN /usr/sbin/useradd makerpm && \
	usermod -G wheel makerpm && \
	sed -i 's/^# %wheel.*$/%wheel ALL = (ALL) NOPASSWD: ALL/' /etc/sudoers && \
	yum -y install git yajl-devel pkgconfig perl-LWP-UserAgent perl-HTTP-Date perl-Digest-HMAC perl-Digest-SHA \
	perl-libwww perl-List-AllUtils perl-Time-HiRes perl-LWP-UserAgent-Determined perl-URI zlib-devel libidn-devel \
	perl-JSON  perl-MIME-Base64perl-Test-Mock-LWP perl-Time-HiRes perl-Test-MockObject perl-UNIVERSAL-can perl-UNIVERSAL-isa

#RUN wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm && \
#	rpm -i ./rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm  && \
#	yum -y install git

# allow to upload packages to the indians
ADD rpmmacros /home/makerpm/.rpmmacros
ADD packages  /home/makerpm/packages
ADD skylable-sx.spec /home/makerpm/
ADD skylable.repo /etc/yum.repos.d/
ADD skel/ /root/
ADD build.sh /usr/bin/


# fix permissions on makerpm
RUN chown -R makerpm.makerpm /home/makerpm/;


#RUN rpmbuild -bs /home/makerpm/skylable-sx.spec && \
#	 yum-builddep /home/makerpm/packages/rpmbuild/SRPMS/skylable-sx*

