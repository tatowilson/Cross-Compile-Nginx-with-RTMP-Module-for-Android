# Cross Compile Nginx with RTMP Module for Android
See full Chinese explanation blog here: https://zhangtom.com/2017/07/11/交叉编译带RTMP模块的Nginx到Android/

Succeed on macOS Sierra 10.12.5

# Prerequisites

* Download latest stable version source code **tarball** of [Nginx](http://nginx.org/en/download.html) (`make_nginx.sh` will extract it automatically)
* Download latest stable version source code of [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module)
* Download and extract latest LTS version source code of [openssl](https://www.openssl.org/source/) 
* Download this repo and place source codes as following:
    ```
    .
    ├── Setenv-android.sh
    ├── glob
    │   ├── glob.c
    │   └── glob.h
    ├── make_nginx.sh
    ├── make_openssl.sh
    │
    ├── nginx-1.12.0.tar.gz
    ├── nginx-rtmp-module
    └── openssl-1.1.0f
    ```
* Download and install `Android SDK` if never installed before, make sure `adb` path is added to environment PATH and it works well
* Download and install `Android NDK` if never installed before, modify `Setenv-android.sh` if needed (`ANDROID_NDK_ROOT`, `_ANDROID_EABI`, `_ANDROID_API`, etc.)

# Build

execute these commands in Terminal:
```bash
# the leading period is important
. ./make_openssl.sh
. ./make_nginx.sh
```

# License

`Setenv-android.sh`: [OpenSSL license]  
`glob.c` and `glob.h`: [BSD-3-Clause License]  
`other files`: [WTFPL]  

[OpenSSL license]:http://www.openssl.org/source/license.html
[BSD-3-Clause License]:https://opensource.org/licenses/BSD-3-Clause
[WTFPL]: http://www.wtfpl.net/