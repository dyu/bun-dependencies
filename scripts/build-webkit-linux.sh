if [ "$GH_ACTIONS" != "true" ] ; then
	source ./scripts/setup-env.sh
fi

# TODO(sno2): add error checks after edgy commands

CC=zcc
CXX=z++
AR=zar

if [ -e deps/icu/source ]; then
    cd deps/icu/source
else
    cd deps
    [ -e icu4c-66_1-src.tgz ] || curl -LO https://github.com/unicode-org/icu/releases/download/release-66-1/icu4c-66_1-src.tgz
    [ -e icu/source ] || tar -xvzf icu4c-66_1-src.tgz
    cd icu/source
fi

if [ ! -e install ]; then
    ./configure \
        CC=$CC \
        CXX=$CXX \
        AR=$AR \
        --prefix=$PWD/install --disable-shared --enable-static --enable-release

    make -j4
    [ -e lib/libicudata.a ] && \
    [ -e lib/libicui18n.a ] && \
    [ -e lib/libicuio.a ] && \
    [ -e lib/libicutu.a ] && \
    [ -e lib/libicuuc.a ] && \
    make install
    [ -e install ] || { printf "Failed to build icu.\n"; exit 1; }
fi

ICU_DIR=$PWD/install
PREFIX_PATH=$ICU_DIR

mkdir -p $WEBKIT_DIR-out
cd $WEBKIT_DIR-out

cmake \
	-DPORT="JSCOnly" \
	-DENABLE_STATIC_JSC=ON \
	-DCMAKE_PREFIX_PATH=$PREFIX_PATH \
	-DCMAKE_BUILD_TYPE=$WEBKIT_RELEASE_TYPE \
	-DUSE_THIN_ARCHIVES=OFF \
	-DENABLE_FTL_JIT=ON \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	-G Ninja \
	-DCMAKE_CXX_COMPILER=$CXX \
	-DCMAKE_C_COMPILER=$CC \
	$WEBKIT_DIR

if [ $? -ne 0 ] ; then
	printf "Failed to build JSC.\n"
	exit 1
fi

CFLAGS="$CFLAGS -ffat-lto-objects" \
CXXFLAGS="$CXXFLAGS -ffat-lto-objects" \
cmake --build $WEBKIT_DIR-out --config $WEBKIT_RELEASE_TYPE -- "jsc" -j$(nproc)

if [ $? -ne 0 ] ; then
	printf "Failed to build WebKit.\n"
	exit 1
fi
