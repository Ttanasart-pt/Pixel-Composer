#!/bin/sh
cd "${0%/*}"

if [ $(uname) = "Linux" ]; then
  g++ borderless.cpp -o libborderless.so -std=c++17 -shared -static-libgcc -static-libstdc++ -lX11
elif [ $(uname) = "FreeBSD" ]; then
  clang++ borderless.cpp -o libborderless.so -std=c++17 -shared -I/usr/local/include -L/usr/local/lib -lX11 -fPIC
fi
