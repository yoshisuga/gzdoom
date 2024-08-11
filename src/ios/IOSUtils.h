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
  GamepadControlRightMouseClick
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
