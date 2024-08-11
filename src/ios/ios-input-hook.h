//
//  ios-input-hook.h
//  GZDoom
//
//  Created by Yoshi Sugawara on 10/24/21.
//

#ifndef ios_input_hook_h
#define ios_input_hook_h

void InputUpdateGUICapture(bool capt);
void IOS_HandleInput();
void IOS_GetMouseDeltas(int *x, int *y);
void IOS_GetGyroDeltas(int *x, int *y);
float IOS_GetAimSensitivity();
int16_t IOS_GetAsciiFromSDLKeyCode(int32_t keyCode);

#endif /* ios_input_hook_h */
