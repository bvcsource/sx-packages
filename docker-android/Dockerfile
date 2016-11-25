FROM centos:centos7


ENV http_proxy http://proxy:3128
ENV https_proxy http://proxy:3128
RUN  echo 'deltarpm=0' >> /etc/yum.conf && \
    sed -i 's/^mirrorlist=/#mirrorlist=/' /etc/yum.repos.d/* && \
    sed -i 's/^#baseurl=/baseurl=/' /etc/yum.repos.d/* && \
    sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf;

# SX repo
ADD skylable.repo /etc/yum.repos.d/

RUN yum clean all

# add EPEL
RUN yum -y install epel-release
# Install Development Tools
RUN yum -y groupinstall "Development Tools"

# yum update
RUN yum -y update

# Install java (OpenJDK)
# Install 32bit Library
RUN yum -y install java-1.7.0-openjdk-devel openssh-server tar bzip2 vim xauth swig wget bzip2 \
	glibc.i686 libstdc++.i686 glibc-devel.i686 zlib-devel.i686 ncurses-devel.i686 libX11-devel.i686 libXrender.i686 \
    skylable-sx

# Install Android SDK
RUN cd /usr/local/ && curl -L -O http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz && tar xf android-sdk_r23.0.2-linux.tgz

# Install Android tools
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter tools --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter platform-tools --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter android-22 --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter extra --no-ui --force -a
RUN echo y | /usr/local/android-sdk-linux/tools/android update sdk --filter build-tools-22.0.1 --no-ui --force -a

# Install Android NDK
# Install Apache-Ant
RUN cd /usr/local && curl -L -O http://dl.google.com/android/ndk/android-ndk32-r10b-linux-x86_64.tar.bz2 && tar xf android-ndk32-r10b-linux-x86_64.tar.bz2 && \
	cd /usr/local/ && curl -L -O http://www.eu.apache.org/dist//ant/binaries/apache-ant-1.9.4-bin.tar.gz && tar xf apache-ant-1.9.4-bin.tar.gz && \
	rm -rf /usr/local/android-ndk32-r10b-linux-x86_64.tar.bz2  /usr/local/android-sdk_r23.0.2-linux.tgz /usr/local/apache-ant-1.9.2-bin.tar.gz

# Environment variables
add bashrc /root/.bashrc

run mkdir /root/.ssh && \
	chmod 700 /root/.ssh && \
	echo X11UseLocalhost no >>/etc/ssh/sshd_config && \
	echo X11Forwarding yes >>/etc/ssh/sshd_config 

#RUN git clone git+ssh://ro@git.dev.skylable.com/home/git/sxdrive-android.git /usr/local/src/sx/android

add build.sh /usr/bin/build.sh
add init.sh /usr/bin/init.sh

