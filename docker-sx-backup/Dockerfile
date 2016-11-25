FROM debian:jessie
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    build-essential git make libcurl4-openssl-dev zlib1g-dev libssl-dev \
    libyajl-dev libfcgi-dev libsqlite3-dev libltdl-dev pkg-config nginx \
    && apt-get clean
RUN git clone http://git.skylable.com/sx && cd sx && git checkout 2.0-1-g74d7354 && \
    ./configure --with-system-libs --disable-sxhttpd && \
    make -j9 && \
    make install && \
    cd ../ && rm -rf sx
COPY backup-sx-appliance.sh /root/bin/
ENV HOME /root
ENTRYPOINT ["/root/bin/backup-sx-appliance.sh"]
