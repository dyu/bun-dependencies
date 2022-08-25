if [ "$GH_ACTIONS" != "true" ] ; then
	source ./scripts/setup-env.sh
fi

mkdir -p $WEBKIT_DIR-out
cd $WEBKIT_DIR-out

CC=zcc
CXX=z++
cmake \
	-DPORT="JSCOnly" \
	-DENABLE_STATIC_JSC=ON \
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

CFLAGS="$CFLAGS -ffat-lto-objects" && \
CXXFLAGS="$CXXFLAGS -ffat-lto-objects" && \
	cmake --build $WEBKIT_DIR-out --config $WEBKIT_RELEASE_TYPE -- "jsc" -j$(sysctl -n hw.logicalcpu)

if [ $? -ne 0 ] ; then
	printf "Failed to build WebKit.\n"
	exit 1
fi
