#!/bin/sh

set -e

GIT_CLONE='git clone --recurse-submodules --shallow-submodules --depth=1 --single-branch -b'

WEBKIT_DIR=deps/WebKit

[ -e $WEBKIT_DIR ] || $GIT_CLONE zig-clang https://github.com/dyu/WebKit.git $WEBKIT_DIR