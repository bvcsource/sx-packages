FROM centos:centos7
MAINTAINER Skylable Dev-Team <dev-team@skylable.com>

COPY skylable.repo /etc/yum.repos.d/skylable.repo


# Install deps
RUN yum clean all && \
    yum -y update && \
    yum -y install epel-release && \
    yum clean all;

RUN yum -y install supervisor python-pip skylable-sx

# Default environment variables
ENV ACCESS_LOG_PATH=/data/logs/sxhttpd-access.log
ENV UPLOAD_INTERVAL=300

# Prepare workdirs
WORKDIR /srv
RUN mkdir /data
RUN mkdir logs sxconsole-logs

COPY sxconsole-logs/ /srv/sxconsole-logs

# Install python deps
WORKDIR /srv/sxconsole-logs
COPY sxconsole-logs/requirements.txt /srv/sxconsole-logs/
RUN pip install -r requirements.txt

# Config files
COPY supervisord.conf /etc/supervisor/
COPY run.sh /

CMD ["/run.sh"]
