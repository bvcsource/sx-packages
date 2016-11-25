FROM debian:7

ADD init.sh /usr/bin/


RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y upgrade && \
    apt-get -y install git make gcc autotools-dev devscripts debianutils && \
    apt-get clean
RUN apt-get update && \
    apt-get install -y debhelper libcurl4-openssl-dev zlib1g-dev libssl-dev \
		libyajl-dev libfcgi-dev \
		libltdl-dev logrotate libfuse-dev fuse pkg-config && \
    apt-get clean

# add debian rules
ADD packages/deb/sx/debian /home/build/sx/debian

# allow to upload packages to the indians
ADD skel/ /root/
ADD build.sh /usr/bin/

