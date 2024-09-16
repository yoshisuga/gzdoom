//
//  ios-input-hook.h
//  GZDoom
//
//  Created by Yoshi Sugawara on 10/24/21.
//

#ifndef ios_input_hook_h
#define ios_input_hook_h

#include "m_joy.h"

void InputUpdateGUICapture(bool capt);
void IOS_HandleInput();
void IOS_HandleJoystickAxes(float axes[NUM_JOYAXIS]);
void IOS_GetMouseDeltas(int *x, int *y);
void IOS_GetGyroDeltas(int *x, int *y);
float IOS_GetAimSensitivity();
int16_t IOS_GetAsciiFromSDLKeyCode(int32_t keyCode);
void IOS_ShowSystemModal(const char* title, const char* message);
void IOS_SpinRunLoop();
bool IOS_DidCancelSystemModal();
void IOS_DismissSystemModal();
void IOS_StartBonjourService();
void IOS_StopBonjourService();

#endif /* ios_input_hook_h */
