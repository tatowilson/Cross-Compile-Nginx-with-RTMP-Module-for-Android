#!/bin/sh

echo "building nginx..."
echo "see logs in make_nginx.log"

exec > make_nginx.log
exec 2>&1
. ./portable_cmds.sh

START_DIR=$PWD
RTMP_MODULE_DIR=$START_DIR/nginx-rtmp-module
CROSS_COMPILE_GCC="$ANDROID_TOOLCHAIN/$CROSS_COMPILE"gcc
export DESTDIR=$START_DIR
export CC_AUX_FLAGS="--sysroot=$ANDROID_SYSROOT"

NGINX_SRC_PKG=$(p_find ".*nginx-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz")
if [ -z $NGINX_SRC_PKG ]; then
    echo "Can't find nginx source package! Aborting." >/dev/tty
    exit 1
fi
NGINX_SRC_DIR=${NGINX_SRC_PKG%.tar.gz}
if [ -d $NGINX_SRC_DIR ]; then
	rm -r $NGINX_SRC_DIR
fi
tar xzf $NGINX_SRC_PKG
command -v adb >/dev/null 2>&1 || { echo >&2 "This script needs adb, but it's not found. Install it and add its path to `PATH`. Aborting." >/dev/tty; exit 1; }
cd $NGINX_SRC_DIR

# modify the auto files and run autotests on Android using adb
# these commands work well on macOS
_ADB_PUSH_AUTOTEST='adb push $NGX_AUTOTEST /data/local/tmp 2>\&1 >/dev/null'
_ADB_RM_AUTOTEST='adb shell rm /data/local/tmp/$(basename $NGX_AUTOTEST)'
_ADB_RUN_AUTOTEST='adb shell /data/local/tmp/$(basename $NGX_AUTOTEST)'
sed -i -e 's@\( *\)case "$ngx_feature_run" in@\1'"$_ADB_PUSH_AUTOTEST"'\
&@' auto/feature
sed -i -e 's@\( *\)esac@&\
\1'"$_ADB_RM_AUTOTEST"'@' auto/feature
sed -i -e 's@/bin/sh -c $NGX_AUTOTEST@'"$_ADB_RUN_AUTOTEST"'@' auto/feature
sed -i -e 's@`$NGX_AUTOTEST`@`'"$_ADB_RUN_AUTOTEST"'`@' auto/feature
# specify --sysroot for autotest in auto/include by adding $CC_AUX_FLAGS (already export above)
sed -i -e 's@ngx_test="$CC -o $NGX_AUTOTEST $NGX_AUTOTEST.c"@ngx_test="$CC $CC_AUX_FLAGS -o $NGX_AUTOTEST $NGX_AUTOTEST.c"@' auto/include
sed -i -e 's@\( *\)ngx_size=`$NGX_AUTOTEST`@\1'"$_ADB_PUSH_AUTOTEST"'\
\1ngx_size=`'"$_ADB_RUN_AUTOTEST"'`\
\1'"$_ADB_RM_AUTOTEST"'@' auto/types/sizeof
# remove unnecessary sub-directory ".openssl/" for already cross-compiled openssl library
sed -i -e 's@\.openssl/@@' auto/lib/openssl/conf
# add glob.h and glob.c to sources
_SRC_OS_UNIX_DIR=src/os/unix
cp ../glob/glob.h $_SRC_OS_UNIX_DIR
cp ../glob/glob.c $_SRC_OS_UNIX_DIR
sed -i -e 's@UNIX_DEPS=.*@&\
'$_SRC_OS_UNIX_DIR/glob.h' \\@' auto/sources
sed -i -e 's@UNIX_SRCS=.*@&\
'$_SRC_OS_UNIX_DIR/glob.c' \\@' auto/sources
# replace crypt() with DES_crypt() in openssl
sed -i -e 's@#include <ngx_core.h>@&\
#include <openssl/des.h>@' $_SRC_OS_UNIX_DIR/ngx_user.c
sed -i -e 's@value = crypt((char \*) key, (char \*) salt);@value = DES_crypt((char \*) key, (char \*) salt);@' $_SRC_OS_UNIX_DIR/ngx_user.c

./configure \
--crossbuild=android-arm \
--prefix=/sdcard/nginx \
--with-http_ssl_module \
--with-openssl=$OPENSSL_DIR \
--without-http_gzip_module \
--without-pcre \
--without-http_rewrite_module \
--without-http_proxy_module \
--without-http_userid_module \
--without-http_upstream_zone_module \
--without-stream_upstream_zone_module \
--add-module=$RTMP_MODULE_DIR \
--with-cc=$CROSS_COMPILE_GCC \
--with-cc-opt="--sysroot=$ANDROID_SYSROOT -Wno-sign-compare -pie -fPIE" \
--with-ld-opt="--sysroot=$ANDROID_SYSROOT -pie -fPIE"

make -j8
make install -j8

cd ..
exec >/dev/tty
exec 2>&1
