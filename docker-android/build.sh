#!/bin/bash

. /root/.bashrc

APPSRC=/usr/local/src/sx

rm -rf $APPSRC
git clone http://git.skylable.com/sx $APPSRC

cp -a /root/sxdrive-android.git $APPSRC/android

cd $APPSRC/android && \
        ./bindgen.sh && \
cd $APPSRC/3rdparty && \
        wget -O openssl-1.0.1m.tar.gz https://www.openssl.org/source/openssl-1.0.1m.tar.gz && \
        tar xvzf openssl-1.0.1m.tar.gz && \
        ln -s openssl-1.0.1m openssl && \
cd $APPSRC/android/import_openssl && \
        cp * $APPSRC/3rdparty/openssl/ && \
cd $APPSRC/3rdparty/openssl && \
        ./import_openssl.sh import ../openssl-1.0.1m.tar.gz && \
cd $APPSRC/android &&
        cat >local.properties <<EOF
sdk.dir=/usr/local/android-sdk-linux
ndk.dir=/usr/local/android-ndk-r10b
ndk.jobs=8
EOF

echo Create gradle.properties file
cat >$APPSRC/android/gradle.properties <<EOF
RELEASE_STORE_FILE=/root/skylable.keystore
RELEASE_STORE_PASSWORD=skylable
RELEASE_KEY_ALIAS=skylable
RELEASE_KEY_PASSWORD=skylable
EOF

echo Starting build in 3 secs...
sleep 3
# OLD: ant debug
# OLD: ant release
# OLD: ant clean

cd $APPSRC/android
# signed apk: ./gradlew assembleRelease
# debug apk: 
./gradlew assembleDebug

ls -al $APPSRC/android/bin/



sxcp --config-dir=/root/.sx $APPSRC/android/bin/SX*.apk sx://indian.skylable.com/vol-packages/experimental-sxdrive/android/
sxcp --config-dir=/root/.sx $APPSRC/android/app/build/outputs/apk/*apk sx://indian.skylable.com/vol-packages/experimental-sxdrive/android/
