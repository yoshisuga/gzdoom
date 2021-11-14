//
//  ios_main.mm
//  GZDoom for iOS
//
//  Created by Yoshi Sugawara on 11/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// macOS: interface to process events, prob handle these in the view controller
// #include "../common/platform/posix/cocoa/i_common.h"
#include "s_soundinternal.h"

#include <sys/sysctl.h>
#include <sys/stat.h>
#include <sys/utsname.h>

#include "c_console.h"
#include "c_cvars.h"
#include "cmdlib.h"
#include "i_system.h"
#include "m_argv.h"

// macOS: the console window, prob not needed for iOS
//#include "st_console.h"

#include "version.h"
#include "printf.h"
#include "s_music.h"
#include "engineerrors.h"

// ---------------------------------------------------------------------------


CVAR (Bool, i_soundinbackground, false, CVAR_ARCHIVE|CVAR_GLOBALCONFIG)
EXTERN_CVAR(Int,  vid_defwidth )
EXTERN_CVAR(Int,  vid_defheight)
EXTERN_CVAR(Bool, vid_vsync    )

int GameMain();

FArgs* Args; // command line arguments: unused for iOS? will we ever pass cmd line args?

// ---------------------------------------------------------------------------

void Mac_I_FatalError(const char* const message)
{
    NSLog(@"Fatal Error: %s", message);
    S_StopMusic(true);
}

void I_DetectOS()
{
    FString operatingSystem;

    const char *paths[] = {"/etc/os-release", "/usr/lib/os-release"};

    for (const char *path : paths)
    {
        struct stat dummy;

        if (stat(path, &dummy) != 0)
            continue;

        char cmdline[256];
        snprintf(cmdline, sizeof cmdline, ". %s && echo ${PRETTY_NAME}", path);

        FILE *proc = popen(cmdline, "r");

        if (proc == nullptr)
            continue;

        char distribution[256] = {};
        fread(distribution, sizeof distribution - 1, 1, proc);

        const size_t length = strlen(distribution);

        if (length > 1)
        {
            distribution[length - 1] = '\0';
            operatingSystem = distribution;
        }

        pclose(proc);
        break;
    }

    utsname unameInfo;

    if (uname(&unameInfo) == 0)
    {
        const char* const separator = operatingSystem.Len() > 0 ? ", " : "";
        operatingSystem.AppendFormat("%s%s %s on %s", separator, unameInfo.sysname, unameInfo.release, unameInfo.machine);
    }

    if (operatingSystem.Len() > 0)
        Printf("OS: %s\n", operatingSystem.GetChars());
}

@interface GZDoomAppDelegate: NSObject<UIApplicationDelegate>
@end

@implementation GZDoomAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [window makeKeyAndVisible];
    
    // TODO: set root view controller
    
    // Run the main entry
    int ret = GameMain();
    if (ret) {
        return false;
    }
    return true;
}

@end

int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([GZDoomAppDelegate class]));
    }
}
