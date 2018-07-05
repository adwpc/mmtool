#!/bin/bash
#adwpc
#it will update your packages !

OBJ=""
CURDIR=$(cd `dirname $0`; pwd)
NAME=`basename $0`
LOG="$CURDIR/$NAME.log"
ERR="$CURDIR/$NAME.err"
#init common
. $CURDIR/common.sh



function ffmpeg_inst()
{
    run sudo yum -y install autoconf automake gettext gcc gcc-c++ make libtool mercurial pkgconfig patch libXext-devel glibc-static libstdc++-static

    export PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
    local src="$HOME/ffmpeg_source"
    local dst="$HOME/ffmpeg_build"
    local bin="$HOME/bin"
    export PATH="$bin:$PATH"

    saferm $dst
    saferm $src
    saferm $bin
    mkdir -p $src

    inst $src https://github.com/yasm/yasm git ./configure --prefix="$dst" --bindir="$bin"
    inst $src http://repo.or.cz/nasm git ./configure --prefix="$dst" --bindir="$bin"
    inst $src https://github.com/openssl/openssl OpenSSL_1_0_2o "./config --prefix=$dst"
    inst $src https://github.com/madler/zlib git ./configure --prefix="$dst" --static
    inst $src https://github.com/webmproject/libvpx git ./configure --prefix="$dst" --disable-shared --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm 
    inst $src https://github.com/webmproject/libwebp git ./configure --prefix="$dst" --disable-shared
    inst $src https://github.com/mirror/x264 git ./configure --prefix="$dst" --bindir="$bin" --enable-static
    # do not use cmake 3 for building x265, x265.pc will be bad for building static ffmpeg
    inst $src https://github.com/videolan/x265 git "cd $src/x265/build/linux \&\& cmake -G \'Unix\ Makefiles\' -DCMAKE_INSTALL_PREFIX=$dst -DENABLE_SHARED:bool=off ../../source"
    inst $src https://github.com/xiph/opus git ./configure --prefix="$dst" --disable-shared
    inst $src https://github.com/mstorsjo/fdk-aac git ./configure --prefix="$dst" --disable-shared
    inst $src https://github.com/xiph/ogg git ./configure --prefix="$dst" --disable-shared
    inst $src https://github.com/xiph/vorbis git ./configure --prefix="$dst" --with-ogg="$dst" --disable-shared
    inst $src https://github.com/xiph/speex git ./configure --prefix="$dst" --disable-shared
    inst $src https://github.com/xiph/theora git ./configure --prefix="$dst" --with-ogg="$dst" --disable-shared
    inst $src git://git.sv.nongnu.org/freetype/freetype2 git ./configure --prefix="$dst" --enable-freetype-config --disable-shared
    inst $src https://github.com/mstorsjo/rtmpdump git "cd $src/rtmpdump/librtmp \&\& sed -i \'s#prefix=/usr/local#prefix=$dst#\' Makefile \&\& sed -i \'s#SHARED=yes#SHARED=no#\' Makefile \&\& sed -i \'s#gcc#gcc -I$dst/include#\' Makefile \&\& sed -i \'s#\(CROSS_COMPILE\)ld#\(CROSS_COMPILE\)ld -L$dst/lib#\' Makefile"
    inst $src https://github.com/SDL-mirror/SDL git ./configure --prefix="$dst" --disable-shared

    inst $src https://sourceforge.net/projects/lame/files/latest/download wget "cd $src/lame* \&\& ./configure --prefix=$dst --bindir=$bin --disable-shared --enable-nasm"

    inst $src https://github.com/Kitware/CMake git ./bootstrap --prefix="$HOME"
    #aom build with cmake 3, master branch，0.1.0 has not CMakeList.txt
    inst $src https://aomedia.googlesource.com/aom master "mkdir -p $dst/aom \&\& cd $dst/aom \&\& cmake -D CMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=$dst $src/aom"

    inst $src https://github.com/FFmpeg/FFmpeg git "./configure --prefix=$dst --enable-hardcoded-tables --pkg-config-flags=--static --extra-cflags=-I$dst/include --extra-ldflags=-L$dst/lib --extra-libs=-lpthread --extra-libs=-lm --extra-ldexeflags=-static --bindir=$bin --enable-gpl --enable-nonfree --enable-openssl --enable-protocol=rtmp --enable-librtmp --enable-demuxer=rtsp --enable-muxer=rtsp --enable-libfreetype --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libtheora --enable-libx264 --enable-libx265 --enable-libvpx --enable-libwebp --enable-ffplay --enable-libaom --disable-shared --enable-static --disable-debug --enable-gpl --enable-nonfree"

}

echo "`date`"
echo "cmd=$0 $@"
echo "log=$LOG"
echo "err=$ERR"
if [ "$1" != "" ];then
    OBJ="$1"
fi

ffmpeg_inst
echo "install end:$0!"


