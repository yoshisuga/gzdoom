//
//  ios_start.m
//  zdoom_native
//
//  Created by Yoshi Sugawara on 11/14/21.
//

#import <Foundation/Foundation.h>

#include "c_cvars.h"
#include "st_start.h"
#include "printf.h"
#include "engineerrors.h"

// FStartupScreen *StartScreen;

FBasicStartupScreen::FBasicStartupScreen(int maxProgress, bool showBar)
: FStartupScreen(maxProgress)
{
    NSLog(@"FBasicStartupScreen: set maxprogress: %i, showBar: %i", maxProgress, showBar);
}

FBasicStartupScreen::~FBasicStartupScreen()
{
    NSLog(@"FBasicStartupScreen deinit?");
}

void FBasicStartupScreen::Progress()
{
    if (CurPos < MaxPos)
    {
        ++CurPos;
    }

    NSLog(@"FBasicStartupScreen::Progress set progress (%i / %i)",CurPos,MaxPos);
}

void FBasicStartupScreen::NetInit(const char* const message, const int playerCount)
{
    NSLog(@"FBasicStartupScreen::NetInit: %s playercount=%i", message, playerCount);
}

void FBasicStartupScreen::NetProgress(const int count)
{
    NSLog(@"FBasicStartupScreen::NetProgress count = %i",count);
}

void FBasicStartupScreen::NetMessage(const char* const format, ...)
{
    va_list args;
    va_start(args, format);

    FString message;
    message.VFormat(format, args);
    va_end(args);

    Printf("%s\n", message.GetChars());
}

void FBasicStartupScreen::NetDone()
{
    NSLog(@"FBasicStartupScreen::NetDone");
}

bool FBasicStartupScreen::NetLoop(bool (*timerCallback)(void*), void* const userData)
{
    while (true)
    {
        if (timerCallback(userData))
        {
            break;
        }

        [[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode];

        // Do not poll to often
        usleep(50000);
    }

    return true;
}


// ---------------------------------------------------------------------------


//FStartupScreen *FStartupScreen::CreateInstance(const int maxProgress, bool showprogress)
//{
//    return new FBasicStartupScreen(maxProgress, showprogress);
//}


// ---------------------------------------------------------------------------


//void ST_Endoom()
//{
//    throw CExitEvent(0);
//}
