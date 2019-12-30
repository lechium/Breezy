#!/bin/bash

SDK_PATH="`xcrun --sdk appletvos --show-sdk-path`"

xcrun -sdk appletvos clang -v -arch arm64 -isysroot $SDK_PATH -Iinclude -F. -F.. -framework Foundation -framework TVServices -framework Sharing -mappletvos-version-min=9.0 -o breezyd breezyd.m 

ldid2 -Sent.plist breezyd
cp breezyd ../layout/usr/bin/

