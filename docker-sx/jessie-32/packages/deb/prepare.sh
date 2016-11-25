#!/bin/sh
for dist in $(debian-distro-info --supported; ubuntu-distro-info --supported)
do
  if test $dist = "experimental"; then
      continue;
  fi;
  for arch in i386 amd64; do
      pbuilder-dist $dist $arch create
  done
done
