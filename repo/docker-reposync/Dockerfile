FROM debian:jessie

ENV http_proxy http://proxy:3128
ENV https_proxy http://proxy:3128

RUN apt-get  update
RUN apt-get -y dist-upgrade && \
	apt-get -y upgrade && \
	apt-get -y install git reprepro createrepo \
		bzr-builddeb vim-nox wget git-buildpackage gnupg 

RUN echo deb http://cdn.skylable.com/debian jessie main >>/etc/apt/sources.list && \
	(wget -qO - http://cdn.skylable.com/GPG-KEY-skylable.asc | sudo apt-key add -)
RUN apt-get update && \
	apt-get -y install sx


ADD skel/ /root/
ADD debian/ /root/debian
ADD update-repo-debs.sh /usr/bin/
ADD update-repo-rpms.sh /usr/bin/
