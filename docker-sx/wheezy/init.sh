#!/bin/bash

service sshd start

shutdown_sxserver() {
    service sshd stop
    exit $?
}

trap shutdown_sxserver SIGINT

while true; do sleep 1; done
