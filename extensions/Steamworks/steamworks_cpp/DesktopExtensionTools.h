//
// Copyright (C) 2020 Opera Norway AS. All rights reserved.
//
// This file is an original work developed by Opera.
//

#include <filesystem>
#include <fstream>
#include <string>

#define tracef(...) do { DebugConsoleOutput("[STEAMWORKS]: "); DebugConsoleOutput(__VA_ARGS__); DebugConsoleOutput("\n"); } while (0)

std::string DesktopExtensionTools_getPathToExe();
