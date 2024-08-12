//
//  IOSUtils.h
//  xm8-ios
//
//  Created by Yoshi Sugawara on 12/12/16.
//
//

#import <Foundation/Foundation.h>
#import <GameController/GameController.h>
#import "ios-glue.h"

@protocol KeyCoded;

typedef NS_ENUM(NSInteger, ThumbstickDirection) {
  ThumbstickDirectionUp,
  ThumbstickDirectionDown,
  ThumbstickDirectionLeft,
  ThumbstickDirectionRight,
};

typedef NS_ENUM(NSInteger, DPadDirection) {
  DPadDirectionUpLeft,
  DPadDirectionUp,
  DPadDirectionUpRight,
  DPadDirectionLeft,
  DPadDirectionNone,
  DPadDirectionRight,
  DPadDirectionDownLeft,
  DPadDirectionDown,
  DPadDirectionDownRight
};

typedef NS_ENUM(NSInteger, GamepadControl) {
  GamepadControlA,
  GamepadControlB,
  GamepadControlX,
  GamepadControlY,
  GamepadControlL,
  GamepadControlR,
  GamepadControlLT,
  GamepadControlRT,
  GamepadControlLS,
  GamepadControlRS,
  GamepadControlSelect,
  GamepadControlStart,
  GamepadControlDpad,
  GamepadControlLeftMouseClick,
  GamepadControlRightMouseClick,
  GamepadControlKB_Esc,
  GamepadControlKB_F1,
  GamepadControlKB_F2,
  GamepadControlKB_F3,
  GamepadControlKB_F4,
  GamepadControlKB_F5,
  GamepadControlKB_F6,
  GamepadControlKB_F7,
  GamepadControlKB_F8,
  GamepadControlKB_F9,
  GamepadControlKB_F10,
  GamepadControlKB_F11,
  GamepadControlKB_F12,
  GamepadControlKB_Tilde,
  GamepadControlKB_1,
  GamepadControlKB_2,
  GamepadControlKB_3,
  GamepadControlKB_4,
  GamepadControlKB_5,
  GamepadControlKB_6,
  GamepadControlKB_7,
  GamepadControlKB_8,
  GamepadControlKB_9,
  GamepadControlKB_0,
  GamepadControlKB_Minus,
  GamepadControlKB_Equal,
  GamepadControlKB_Backspace,
  GamepadControlKB_Tab,
  GamepadControlKB_Q,
  GamepadControlKB_W,
  GamepadControlKB_E,
  GamepadControlKB_R,
  GamepadControlKB_T,
  GamepadControlKB_Y,
  GamepadControlKB_U,
  GamepadControlKB_I,
  GamepadControlKB_O,
  GamepadControlKB_P,
  GamepadControlKB_LeftBracket,
  GamepadControlKB_RightBracket,
  GamepadControlKB_Backslash,
  GamepadControlKB_A,
  GamepadControlKB_S,
  GamepadControlKB_D,
  GamepadControlKB_F,
  GamepadControlKB_G,
  GamepadControlKB_H,
  GamepadControlKB_J,
  GamepadControlKB_K,
  GamepadControlKB_L,
  GamepadControlKB_Semicolon,
  GamepadControlKB_Quote,
  GamepadControlKB_Return,
  GamepadControlKB_Shift,
  GamepadControlKB_Z,
  GamepadControlKB_X,
  GamepadControlKB_C,
  GamepadControlKB_V,
  GamepadControlKB_B,
  GamepadControlKB_N,
  GamepadControlKB_M,
  GamepadControlKB_Comma,
  GamepadControlKB_Period,
  GamepadControlKB_Slash,
  GamepadControlKB_Control,
  GamepadControlKB_Alt,
  GamepadControlKB_Space,
  GamepadControlKB_Up,
  GamepadControlKB_Left,
  GamepadControlKB_Right,
  GamepadControlKB_Down,
  GamepadControlKB_Home,
  GamepadControlKB_Insert,
  GamepadControlKB_End,
  GamepadControlKB_PageUp,
  GamepadControlKB_PageDown,
  GamepadControlKB_Del
};

@interface IOSUtils : NSObject

+(instancetype)shared;
-(void)doMain;

// Input hooks for GZDoom
-(void)mouseMoveWithX:(NSInteger)x Y:(NSInteger)y;

-(void)handleGameControl:(GamepadControl)gamepadControl isPressed:(BOOL)isPressed;

-(void)handleGameControllerInputForGamepad:(GCExtendedGamepad*)gamepad button:(GCControllerButtonInput*)button isPressed:(BOOL)isPressed;

-(void)handleLeftThumbstickDirectionalInput:(ThumbstickDirection)direction isPressed:(BOOL)isPressed;

-(void)handleOverlayDPadWithDirection:(DPadDirection)direction;
-(void)handleOverlayButtonName:(NSString*)buttonName isPressed:(BOOL)isPressed;
-(void)handleLeftMouseButtonWithPressed:(BOOL)isPressed;

- (void)keyUp:(id<KeyCoded> _Nonnull)key;
- (void)keyDown:(id<KeyCoded> _Nonnull)key;

@end
