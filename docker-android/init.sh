#!/bin/bash -x

adduser -u 1002 buildbot
chown -R buildbot /home/buildbot

/usr/sbin/sshd -D

shutdown_sxserver() {
    exit $?
}

trap shutdown_sxserver SIGINT


