#!/bin/sh
cd "${0%/*}"

if [ $(uname) = "Darwin" ]; then
  clang++ -c gamemaker.cpp lib/cproc/cproc.cpp lib/xproc/xproc.cpp -I. -shared -std=c++17 -Wno-unused-command-line-argument -DPROCESS_GUIWINDOW_IMPL -framework AppKit -framework CoreFoundation -framework CoreGraphics -ObjC++ -arch arm64 -arch x86_64 && clang++ gamemaker.o cproc.o xproc.o -o libxprocess.dylib -I. -shared -std=c++17 -Wno-unused-command-line-argument -DPROCESS_GUIWINDOW_IMPL -framework CoreFoundation -framework CoreGraphics -framework AppKit -ObjC++ -arch arm64 -arch x86_64;
  ar rc libxprocess.a gamemaker.o cproc.o xproc.o && rm -f "gamemaker.o" "cocoa.o" "cproc.o" "xproc.o";
elif [ $(uname) = "Linux" ]; then
  g++ -c gamemaker.cpp lib/cproc/cproc.cpp lib/xproc/xproc.cpp -I. -shared -std=c++17 -static-libgcc -static-libstdc++ -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC && g++ gamemaker.o cproc.o xproc.o -o  libxprocess.so -I. -shared -std=c++17 -static-libgcc -static-libstdc++ -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC;
  ar rc libxprocess.a gamemaker.o cproc.o xproc.o && rm -f "gamemaker.o" "cproc.o" "xproc.o";
elif [ $(uname) = "FreeBSD" ]; then
  clang++ -c gamemaker.cpp lib/cproc/cproc.cpp lib/xproc/xproc.cpp -I. -shared -std=c++17 -I/usr/local/include -L/usr/local/lib -lprocstat -lutil -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC && clang++ gamemaker.o cproc.o xproc.o -o libxprocess.so -I. -shared -std=c++17 -I/usr/local/include -L/usr/local/lib -lprocstat -lutil -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC;
  ar rc libxprocess.a gamemaker.o cproc.o xproc.o && rm -f "gamemaker.o" "cproc.o" "xproc.o";
elif [ $(uname) = "DragonFly" ]; then
  g++ -c gamemaker.cpp lib/cproc/cproc.cpp lib/xproc/xproc.cpp -I. -shared -std=c++17 -I/usr/local/include -L/usr/local/lib -static-libgcc -static-libstdc++ -lkvm -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC && g++ gamemaker.o cproc.o xproc.o -o libxprocess.so -I. -shared -std=c++17 -I/usr/local/include -L/usr/local/lib -lkvm -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC;
  ar rc libxprocess.a gamemaker.o cproc.o xproc.o && rm -f "gamemaker.o" "cproc.o" "xproc.o";
elif [ $(uname) = "NetBSD" ]; then
  g++ -c gamemaker.cpp lib/cproc/cproc.cpp lib/xproc/xproc.cpp -I. -shared -std=c++17 -I/usr/local/include -L/usr/local/lib -static-libgcc -static-libstdc++ -lkvm -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC && g++ gamemaker.o cproc.o xproc.o -o libxprocess.so -I. -shared -std=c++17 -I/usr/local/include -L/usr/local/lib -lkvm -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC;
  ar rc libxprocess.a gamemaker.o cproc.o xproc.o && rm -f "gamemaker.o" "cproc.o" "xproc.o";
elif [ $(uname) = "OpenBSD" ]; then
  clang++ -c gamemaker.cpp lib/cproc/cproc.cpp lib/xproc/xproc.cpp -I. -shared -std=c++17 -I/usr/local/include -L/usr/local/lib -lkvm -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC && clang++ gamemaker.o cproc.o xproc.o -o libxprocess.so -I. -shared -std=c++17 -I/usr/local/include -L/usr/local/lib -lkvm -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC;
  ar rc libxprocess.a gamemaker.o cproc.o xproc.o && rm -f "gamemaker.o" "cproc.o" "xproc.o";
elif [ $(uname) = "SunOS" ]; then
  g++ -c gamemaker.cpp lib/cproc/cproc.cpp lib/xproc/xproc.cpp -I. -shared -std=c++17 -static-libgcc -lkvm -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC && g++ gamemaker.o cproc.o xproc.o -o libxprocess.so -I. -shared -std=c++17 -lkvm -lc -lpthread -DPROCESS_GUIWINDOW_IMPL `pkg-config x11 --cflags --libs` -fPIC;
  ar rc libxprocess.a gamemaker.o cproc.o xproc.o && rm -f "gamemaker.o" "cproc.o" "xproc.o";
else
  g++ -c gamemaker.cpp lib/cproc/cproc.cpp lib/xproc/xproc.cpp -I. -shared -std=c++17 -static-libgcc -static-libstdc++ -static -DPROCESS_GUIWINDOW_IMPL && g++ gamemaker.o cproc.o xproc.o -o  libxprocess.dll -I. -shared -std=c++17 -static-libgcc -static-libstdc++ -static -lntdll -DPROCESS_GUIWINDOW_IMPL;
  ar rc libxprocess.a gamemaker.o cproc.o xproc.o && rm -f "apiprocess/process32.h" "apiprocess/process64.h" "gamemaker.o" "cproc.o" "xproc.o";
fi
