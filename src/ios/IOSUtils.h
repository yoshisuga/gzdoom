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

@interface IOSUtils : NSObject

+(instancetype)shared;
-(void)doMain;

// Input hooks for GZDoom
-(void)mouseMoveWithX:(NSInteger)x Y:(NSInteger)y;

-(void)handleGameControllerInputForGamepad:(GCExtendedGamepad*)gamepad button:(GCControllerButtonInput*)button isPressed:(BOOL)isPressed;

-(void)handleLeftThumbstickDirectionalInput:(ThumbstickDirection)direction isPressed:(BOOL)isPressed;

-(void)handleOverlayDPadWithDirection:(DPadDirection)direction;
-(void)handleOverlayButtonName:(NSString*)buttonName isPressed:(BOOL)isPressed;

@end
