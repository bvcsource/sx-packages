FROM ubuntu:precise

ADD init.sh /usr/bin/

ENV http_proxy http://proxy:3128
ENV https_proxy http://proxy:3128

RUN apt-get update
RUN apt-get -y dist-upgrade && \
	apt-get -y upgrade && \
	apt-get -y install git make gcc libcurl4-openssl-dev zlib1g-dev libssl-dev git \
		autotools-dev libyajl-dev libfcgi-dev check debhelper \
		devscripts debianutils bzr-builddeb vim-nox libltdl-dev logrotate


# add debian rules
ADD packages/deb/sx/debian /home/build/sx/debian

ADD skel/ /root/
ADD build.sh /usr/bin/

