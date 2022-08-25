#!/bin/sh

#/usr/local/bin/zcc
#________begin
#!/bin/sh
#zig cc $ZCC_OPTS $@
#________end

UNAME=`uname`

if [ "$UNAME" = "Darwin" ]; then
    bash ./scripts/build-webkit-macos.sh
elif [ "$UNAME" = "Linux" ]; then
    ZCC_OPTS='-target x86_64-linux-gnu.2.23' bash ./scripts/build-webkit-linux.sh
else
    echo TODO windows
fi

