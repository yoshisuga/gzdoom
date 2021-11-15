//
//  ios_input.m
//  zdoom_native
//
//  Created by Yoshi Sugawara on 11/14/21.
//

#import <Foundation/Foundation.h>

#include "c_console.h"
#include "c_cvars.h"
#include "c_dispatch.h"
#include "d_eventbase.h"
#include "c_buttons.h"
#include "d_gui.h"
#include "dikeys.h"
#include "v_video.h"
#include "i_interface.h"
#include "menustate.h"
#include "engineerrors.h"
#include "keydef.h"
#include "m_joy.h"

#include "ios-input-hook.h"

bool GUICapture;

void CheckGUICapture()
{
    bool wantCapt = sysCallbacks.WantGuiCapture && sysCallbacks.WantGuiCapture();

    if (wantCapt != GUICapture)
    {
        GUICapture = wantCapt;
        InputUpdateGUICapture(GUICapture);
        if (wantCapt)
        {
            buttonMap.ResetButtonStates();
        }
    }
}

void I_GetEvent ()
{
    // i guess this does a run loop but maybe we can set some input vars from the view controller
    [[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode];
}

void I_StartTic()
{
    CheckGUICapture();
    I_GetEvent();
}

void I_StartFrame()
{
}


void I_SetMouseCapture()
{
}

void I_ReleaseMouseCapture()
{
}

void I_GetAxes(float axes[NUM_JOYAXIS])
{
  // read mfi input from view controller and get the values here..maybe
}
