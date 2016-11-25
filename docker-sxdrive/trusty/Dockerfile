FROM ubuntu:trusty


RUN apt-get update
RUN apt-get -y dist-upgrade && \
	apt-get -y upgrade && \
	apt-get -y install git make gcc libcurl4-openssl-dev zlib1g-dev libssl-dev git \
		autotools-dev libyajl-dev libfcgi-dev check debhelper \
		libssl-dev devscripts debianutils bzr-builddeb vim-nox wget git-buildpackage \
		qttools5-dev-tools qt5-qmake qt5-default

#RUN echo deb http://cdn.skylable.com/debian trusty main >>/etc/apt/sources.list && \
#	(wget -qO - http://cdn.skylable.com/GPG-KEY-skylable.asc | sudo apt-key add -)
#RUN apt-get update && apt-get -y install sx
RUN git clone http://git.skylable.com/sx /tmp/sx && \
        cd /tmp/sx && \
        ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && \
        make -j 8 && \
        make install

ADD skel/ /root/
ADD build.sh /usr/bin/

ADD init.sh /usr/bin/

