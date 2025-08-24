
#import <Foundation/Foundation.h>

#include "DesktopExtensionTools.h"

#include "Extension_Interface.h"

#include <filesystem>
#include <string>

#include <stdio.h>

std::string DesktopExtensionTools_getPathToExe()
{
    NSString *bundlename = [[NSBundle mainBundle] executablePath];
    NSString *exePath = [bundlename stringByDeletingLastPathComponent];
        
    return std::string([exePath UTF8String]);
}
