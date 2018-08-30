#!/bin/sh

echo "building openssl..."

exec > make_openssl.log
exec 2>&1
. ./portable_cmds.sh

# 执行环境脚本，第一个句点不能省略
. ./Setenv-android.sh
export OPENSSL_DIR=/usr/local/ssl/$ANDROID_API
# 进入openssl源码目录
OPENSSL_SRC_DIR=$(p_find ".*openssl-[0-9]+\.[0-9]+\.[0-9]+[a-z]")
if [[ -z $OPENSSL_SRC_DIR ]]; then
    echo "Can't find openssl source directory!"
    exit 1
fi
cd $OPENSSL_SRC_DIR
# 生成Makefile
KERNEL_BITS=32 ./config shared no-ssl2 no-ssl3 no-comp no-hw no-engine \
     --openssldir=$OPENSSL_DIR --prefix=$OPENSSL_DIR
make depend
make all
# -E 保留当前的环境变量给root用户
sudo -E make install CC=$ANDROID_TOOLCHAIN/arm-linux-androideabi-gcc RANLIB=$ANDROID_TOOLCHAIN/arm-linux-androideabi-ranlib

cd ..
exec >/dev/tty
echo "see logs in make_openssl.log"