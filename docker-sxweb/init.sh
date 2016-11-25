#!/bin/bash

yum clean all
yum update
set -e 
yum -y install skylable-sx

nginx
php-fpm 
