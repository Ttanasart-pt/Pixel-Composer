#!/bin/sh
cd "${0%/*}";
if [ $(uname) = "Darwin" ]; then
  clang++ -c "filesystem.cpp" "gamemaker.cpp" -shared -std=c++17 -arch arm64 -arch x86_64 && clang++ "filesystem.o" "gamemaker.o" -o "libfilesystem.dylib" -shared -std=c++17 -arch arm64 -arch x86_64; 
  ar rc libfilesystem.a gamemaker.o filesystem.o && rm -f "gamemaker.o" "filesystem.o";
elif [ $(uname) = "Linux" ]; then
  g++ -c "filesystem.cpp" "gamemaker.cpp" -shared -std=c++17 -static-libgcc -static-libstdc++ -lpthread -fPIC && g++ "filesystem.o" "gamemaker.o" -o "libfilesystem.so" -shared -std=c++17 -static-libgcc -static-libstdc++ -lpthread -fPIC;
  ar rc libfilesystem.a gamemaker.o filesystem.o && rm -f "gamemaker.o" "filesystem.o";
elif [ $(uname) = "FreeBSD" ]; then
  clang++ -c "filesystem.cpp" "gamemaker.cpp" -shared -std=c++17 -lc -lpthread -fPIC && clang++ "filesystem.o" "gamemaker.o"  -o "libfilesystem.so" -shared -std=c++17 -lc -lpthread -fPIC;
  ar rc libfilesystem.a gamemaker.o filesystem.o && rm -f "gamemaker.o" "filesystem.o";
elif [ $(uname) = "DragonFly" ]; then
  g++ -c "filesystem.cpp" "gamemaker.cpp" -shared -std=c++17 -static-libgcc -static-libstdc++ -lpthread -fPIC && g++ "filesystem.o" "gamemaker.o"  -o "libfilesystem.so" -shared -std=c++17 -static-libgcc -static-libstdc++ -lpthread -fPIC;
  ar rc libfilesystem.a gamemaker.o filesystem.o && rm -f "gamemaker.o" "filesystem.o";
elif [ $(uname) = "NetBSD" ]; then
  g++ -c "filesystem.cpp" "gamemaker.cpp" -shared -std=c++17 -static-libgcc -static-libstdc++ -lpthread -fPIC && g++ "filesystem.o" "gamemaker.o"  -o "libfilesystem.so" -shared -std=c++17 -static-libgcc -static-libstdc++ -lpthread -fPIC;
  ar rc libfilesystem.a gamemaker.o filesystem.o && rm -f "gamemaker.o" "filesystem.o";
elif [ $(uname) = "OpenBSD" ]; then
  clang++ -c "filesystem.cpp" "gamemaker.cpp" -shared -std=c++17 -lc -lkvm -lpthread -fPIC && clang++ "filesystem.o" "gamemaker.o"  -o "libfilesystem.so" -shared -std=c++17 -lc -lkvm -lpthread -fPIC;
  ar rc libfilesystem.a gamemaker.o filesystem.o && rm -f "gamemaker.o" "filesystem.o";
elif [ $(uname) = "SunOS" ]; then
  g++ -c "filesystem.cpp" "gamemaker.cpp" -shared -std=c++17 -static-libgcc -lpthread -fPIC && g++ "filesystem.o" "gamemaker.o"  -o "libfilesystem.so" -shared -std=c++17 -static-libgcc -lpthread -fPIC;
  ar rc libfilesystem.a gamemaker.o filesystem.o && rm -f "gamemaker.o" "filesystem.o";
else
  g++ -c "filesystem.cpp" "gamemaker.cpp" -shared -std=c++17 -static-libgcc -static-libstdc++ -lshell32 -lole32 -luuid -static && g++ "filesystem.o" "gamemaker.o"  -o "libfilesystem.dll" -shared -std=c++17 -static-libgcc -static-libstdc++ -lshell32 -lole32 -luuid -static;
  ar rc libfilesystem.a gamemaker.o filesystem.o && rm -f "gamemaker.o" "filesystem.o";
fi;
