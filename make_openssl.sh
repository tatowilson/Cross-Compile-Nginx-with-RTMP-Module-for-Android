#!/bin/sh

echo "building openssl..."
echo "see logs in make_openssl.log"

exec > make_openssl.log
exec 2>&1

. ./portable_cmds.sh
. ./Setenv-android.sh
export OPENSSL_DIR=$PWD/ssl/$ANDROID_API

if [ -e $OPENSSL_DIR ]; then
    rm -r $OPENSSL_DIR
fi

# enter openssl source code directory
OPENSSL_SRC_DIR=$(p_find ".*openssl-[0-9]+\.[0-9]+\.[0-9]+[a-z]")
if [[ -z $OPENSSL_SRC_DIR ]]; then
    echo "Can't find openssl source directory!"
    exit 1
fi
cd $OPENSSL_SRC_DIR

# generate Makefile
KERNEL_BITS=32 ./config shared no-ssl2 no-ssl3 no-comp no-hw no-engine \
     --openssldir=$OPENSSL_DIR --prefix=$OPENSSL_DIR
make depend
make all
make install CC=$ANDROID_TOOLCHAIN/arm-linux-androideabi-gcc RANLIB=$ANDROID_TOOLCHAIN/arm-linux-androideabi-ranlib

cd ..
exec >/dev/tty
exec 2>&1
