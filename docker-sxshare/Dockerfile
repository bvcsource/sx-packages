FROM centos:centos7
MAINTAINER Skylable Dev-Team <dev-team@skylable.com>

# Install deps
RUN yum clean all && \
    yum -y update && \
    yum -y install epel-release && \
    yum clean all;

RUN yum -y install nginx supervisor python-pip pwgen python-devel py-bcrypt git gettext

# prepare logs and workdirs
WORKDIR /srv
RUN mkdir -p media static sxshare
VOLUME ["/srv/static/"]

# install deps
RUN pip install flup gunicorn 
WORKDIR /srv/sxshare
COPY sxshare/requirements.txt /srv/sxshare/
# install pip deps
RUN pip install -r requirements.txt

# copy sxshare localization
COPY sx-translations/ /srv/sx-translations

# copy sxshare app
COPY sxshare/ /srv/sxshare

# config files
COPY nginx-sxshare.conf /etc/nginx/conf.d/
COPY nginx.conf /etc/nginx/
COPY custom_50x.html /var/www/error_pages/
COPY supervisord.conf /etc/supervisor/
COPY run.sh /

EXPOSE 443 8000
CMD ["/run.sh"]

