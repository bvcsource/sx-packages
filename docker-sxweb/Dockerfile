from centos:centos7

run yum clean all && \
	yum -y update && \
	yum -y install epel-release && \
	yum -y install php-cli php-fpm php-mysql \
		php-ZendFramework php-ZendFramework-Db-Adapter-Pdo-Mysql \
		php-guzzlehttp-streams.noarch php-guzzle-Guzzle.noarch php-Monolog.noarch nginx \
		strace sudo wget bwm-ng telnet && \
	yum clean all;

run yum -y install gcc git make vim openssl-devel pcre-devel nss-devel libcurl-devel \ 
		fcgi-devel --enablerepo=centosplus && \
	yum clean all;

copy skylable.repo /etc/yum.repos.d/
copy nginx-sxweb.conf /etc/nginx/conf.d/
copy nginx.conf /etc/nginx/
copy php-fpm-www.conf /etc/php-fpm.d/www.conf
copy init.sh /usr/bin/

run mkdir -p /var/lib/php/session
run chown apache:apache /var/lib/php/session


