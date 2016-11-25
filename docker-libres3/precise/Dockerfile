FROM ubuntu:precise


COPY GPG-KEY-skylable.asc /root/
RUN echo deb http://cdn.skylable.com/debian precise main >>/etc/apt/sources.list && \
    apt-key add /root/GPG-KEY-skylable.asc \
    && apt-get update && apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends \
                    build-essential fakeroot devscripts \
                    pbuilder aptitude\
                    sx git && \
    apt-get clean

RUN /usr/sbin/useradd -u 2000 -m build

# add debian rules

COPY skel/ /home/build/
COPY build.sh /usr/bin/

WORKDIR /home/build
COPY debian /home/build/debian
RUN /usr/lib/pbuilder/pbuilder-satisfydepends && \
    apt-get purge -y pbuilder aptitude && apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /home/build/debian

USER build
