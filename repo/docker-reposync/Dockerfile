FROM debian:jessie


RUN apt-get  update
RUN apt-get -y dist-upgrade && \
	apt-get -y upgrade && \
	apt-get -y install git reprepro createrepo \
		bzr-builddeb vim-nox wget git-buildpackage gnupg 

RUN echo deb http://cdn.skylable.com/debian jessie main >>/etc/apt/sources.list && \
	(wget -qO - http://cdn.skylable.com/GPG-KEY-skylable.asc | sudo apt-key add -)
#RUN apt-get update && \
#	apt-get -y install sx
RUN apt-get -y install make gcc libcurl4-openssl-dev zlib1g-dev libssl-dev libfuse-dev git && \
	git clone http://git.skylable.com/sx /tmp/sx && \
        cd /tmp/sx && \
        ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && \
        make -j 8 && \
        make install

ADD skel/ /root/
ADD debian/ /root/debian
ADD update-repo-debs.sh /usr/bin/
ADD update-repo-rpms.sh /usr/bin/
COPY rpmmacros /root/.rpmmacros
