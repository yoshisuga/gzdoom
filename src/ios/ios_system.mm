//
//  ios_system.mm
//  zdoom_native
//
//  Created by Yoshi Sugawara on 11/13/21.
//

#import <Foundation/Foundation.h>

#include <fnmatch.h>
#include <sys/sysctl.h>

#include "i_system.h"

double PerfToSec, PerfToMillisec;

void CalculateCPUSpeed()
{
    long long frequency;
    size_t size = sizeof frequency;

    if (0 == sysctlbyname("machdep.tsc.frequency", &frequency, &size, nullptr, 0) && 0 != frequency)
    {
        PerfToSec = 1.0 / frequency;
        PerfToMillisec = 1000.0 / frequency;
        printf("CPU speed: %.0f MHz\n", 0.001 / PerfToMillisec);
    }
}

void I_SetIWADInfo()
{
    NSLog(@"I_SetIWadInfo: No implementation for iOS");
}

void I_PrintStr(const char* const message)
{
    NSLog(@"I_PrintStr: %s", message);
}

void Mac_I_FatalError(const char* const message);

void I_ShowFatalError(const char *message)
{
    Mac_I_FatalError(message);
}

int I_PickIWad(WadStuff* const wads, const int numwads, const bool showwin, const int defaultiwad)
{
    // not sure if we can support this for iOS...
    return 0;
}

void I_PutInClipboard(const char* const string)
{
    NSLog(@"I_PutInClipboard: No iOS implementation....");
}

FString I_GetFromClipboard(bool returnNothing)
{
    NSLog(@"I_GetFromClipboard: No iOS implementation....");
    return FString();
}

unsigned int I_MakeRNGSeed()
{
    return static_cast<unsigned int>(arc4random());
}
