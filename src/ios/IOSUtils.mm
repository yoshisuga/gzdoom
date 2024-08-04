//
//  IOSUtils.m
//
//  Created by Yoshi Sugawara on 12/12/16.
//
//

#import "IOSUtils.h"
#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>

#import "gzdoom-Swift.h"

#include "ios-glue.h"
#include "video-hook.h"
#include "SDL_syswm.h"
#include "d_eventbase.h"
#include "ios-input-hook.h"
#include "m_argv.h"
#include "keydef.h"

int GameMain();
FArgs *args;

void ios_get_base_path(char *path) {
    NSArray *paths;
    NSString *DocumentsDirPath;
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentsDirPath = [paths objectAtIndex:0];
    sprintf(path, "%s/", [DocumentsDirPath UTF8String]);
}

void ios_get_screen_width_height(int *width, int *height) {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    *height = (int) screenRect.size.width;
    *width = (int) screenRect.size.height;
}

UIViewController* GetSDLViewController(SDL_Window *sdlWindow) {
    SDL_SysWMinfo systemWindowInfo;
    SDL_VERSION(&systemWindowInfo.version);
    if ( ! SDL_GetWindowWMInfo(sdlWindow, &systemWindowInfo)) {
        // error handle?
        return nil;
    }
    UIWindow *appWindow = systemWindowInfo.info.uikit.window;
    UIViewController *rootVC = appWindow.rootViewController;
    return rootVC;
}

void SDLWindowAfterCreate(SDL_Window *window) {
    UIViewController *rootVC = GetSDLViewController(window);
    NSLog(@"root VC = %@",rootVC);
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"Documents path: %@",docsPath);
    IOSUtils *iosUtils = [IOSUtils shared];
    EmulatorKeyboardController *keyboardController = [[EmulatorKeyboardController alloc] initWithLeftKeyboardModel:iosUtils.leftKeyboardModel rightKeyboardModel:iosUtils.rightKeyboardModel];
    keyboardController.rightKeyboardModel.delegate = (id<EmulatorKeyboardKeyPressedDelegate>)iosUtils;
    keyboardController.leftKeyboardModel.delegate = (id<EmulatorKeyboardKeyPressedDelegate>)iosUtils;
    [rootVC addChildViewController:keyboardController];
    [keyboardController didMoveToParentViewController:rootVC];
    keyboardController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [rootVC.view addSubview:keyboardController.view];
    [[keyboardController.view.leadingAnchor constraintEqualToAnchor:rootVC.view.leadingAnchor] setActive:YES];
    [[keyboardController.view.trailingAnchor constraintEqualToAnchor:rootVC.view.trailingAnchor] setActive:YES];
    [[keyboardController.view.topAnchor constraintEqualToAnchor:rootVC.view.topAnchor] setActive:YES];
    [[keyboardController.view.bottomAnchor constraintEqualToAnchor:rootVC.view.bottomAnchor] setActive:YES];
//    [[GameControllerHandler shared] setupVirtualIfNeeded];
}

void SDLWindowAfterSurfaceCreate(SDL_Window *window) {
    UIViewController *rootVC = GetSDLViewController(window);
    UIView *view = rootVC.view;
    NSLog(@"view = %@",view);
}

bool guiCapture = false;
void InputUpdateGUICapture(bool capt) {
    guiCapture = capt;
}

void IOS_HandleInput() {
  GameControllerHandler *gcHandler = [GameControllerHandler shared];
  [gcHandler handleInput];
}

void IOS_GetMouseDeltas(int *x, int *y) {
  MouseInputHolder *mouse = [MouseInputHolder shared];
  if (x) {
    *x = (int) mouse.deltaX;
  }
  if (y) {
    *y = (int) mouse.deltaY;
  }
}

void IOS_GetGyroDeltas(int *x, int *y) {
  MouseInputHolder *mouse = [MouseInputHolder shared];
  if (x) {
    *x = (int) mouse.gyroDeltaX;
  }
  if (y) {
    *y = (int) mouse.gyroDeltaY;
  }
}

float IOS_GetAimSensitivity() {
  return ObjCControlOptionsViewModel.aimSensitivity;
}

const UInt8 DIK_TO_ASCII[128] =
{
    DIK_A, DIK_S, DIK_D, DIK_F, DIK_H, DIK_G, DIK_Z, DIK_X,
    DIK_C, DIK_V, 0, DIK_B, DIK_Q
};

@interface IOSUtils()<EmulatorKeyboardKeyPressedDelegate>
@end

@implementation IOSUtils

+(instancetype)shared {
  static IOSUtils *iosUtils = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    iosUtils = [[self alloc] init];
  });
  return iosUtils;
}

-(id)init {
  self = [super init];
  return self;
}

-(void)doMain {
  GameMain();
}

-(NSDictionary*)dikToAsciiMap {
  return @{
    @(DIK_1) : [NSNumber numberWithUnsignedChar:'1'],
    @(DIK_2) : [NSNumber numberWithUnsignedChar:'2'],
    @(DIK_3) : [NSNumber numberWithUnsignedChar:'3'],
    @(DIK_4) : [NSNumber numberWithUnsignedChar:'4'],
    @(DIK_5) : [NSNumber numberWithUnsignedChar:'5'],
    @(DIK_6) : [NSNumber numberWithUnsignedChar:'6'],
    @(DIK_7) : [NSNumber numberWithUnsignedChar:'7'],
    @(DIK_8) : [NSNumber numberWithUnsignedChar:'8'],
    @(DIK_9) : [NSNumber numberWithUnsignedChar:'9'],
    @(DIK_0) : [NSNumber numberWithUnsignedChar:'0'],
    @(DIK_MINUS) : [NSNumber numberWithUnsignedChar:'-'],
    @(DIK_EQUALS) : [NSNumber numberWithUnsignedChar:'='],
    @(DIK_Q) : [NSNumber numberWithUnsignedChar:'q'],
    @(DIK_W) : [NSNumber numberWithUnsignedChar:'w'],
    @(DIK_E) : [NSNumber numberWithUnsignedChar:'e'],
    @(DIK_R) : [NSNumber numberWithUnsignedChar:'r'],
    @(DIK_T) : [NSNumber numberWithUnsignedChar:'t'],
    @(DIK_Y) : [NSNumber numberWithUnsignedChar:'y'],
    @(DIK_U) : [NSNumber numberWithUnsignedChar:'u'],
    @(DIK_I) : [NSNumber numberWithUnsignedChar:'i'],
    @(DIK_O) : [NSNumber numberWithUnsignedChar:'o'],
    @(DIK_P) : [NSNumber numberWithUnsignedChar:'p'],
    @(DIK_LBRACKET) : [NSNumber numberWithUnsignedChar:'['],
    @(DIK_RBRACKET) : [NSNumber numberWithUnsignedChar:']'],
    @(DIK_BACKSLASH) : [NSNumber numberWithUnsignedChar:'\\'],
    @(DIK_A) : [NSNumber numberWithUnsignedChar:'a'],
    @(DIK_S) : [NSNumber numberWithUnsignedChar:'s'],
    @(DIK_D) : [NSNumber numberWithUnsignedChar:'d'],
    @(DIK_F) : [NSNumber numberWithUnsignedChar:'f'],
    @(DIK_G) : [NSNumber numberWithUnsignedChar:'g'],
    @(DIK_H) : [NSNumber numberWithUnsignedChar:'h'],
    @(DIK_J) : [NSNumber numberWithUnsignedChar:'j'],
    @(DIK_K) : [NSNumber numberWithUnsignedChar:'k'],
    @(DIK_L) : [NSNumber numberWithUnsignedChar:'l'],
    @(DIK_SEMICOLON) : [NSNumber numberWithUnsignedChar:';'],
    @(DIK_APOSTROPHE) : [NSNumber numberWithUnsignedChar:'\''],
    @(DIK_Z) : [NSNumber numberWithUnsignedChar:'z'],
    @(DIK_X) : [NSNumber numberWithUnsignedChar:'x'],
    @(DIK_C) : [NSNumber numberWithUnsignedChar:'c'],
    @(DIK_V) : [NSNumber numberWithUnsignedChar:'v'],
    @(DIK_B) : [NSNumber numberWithUnsignedChar:'b'],
    @(DIK_N) : [NSNumber numberWithUnsignedChar:'n'],
    @(DIK_M) : [NSNumber numberWithUnsignedChar:'m'],
    @(DIK_COMMA) : [NSNumber numberWithUnsignedChar:','],
    @(DIK_PERIOD) : [NSNumber numberWithUnsignedChar:'.'],
    @(DIK_SLASH) : [NSNumber numberWithUnsignedChar:'/'],
    @(DIK_SPACE) : [NSNumber numberWithUnsignedChar:' ']
  };
}

-(void)keyDownInternal:(NSInteger)keyCode label:(NSString*)label {
  event_t event = {};
  event.type = EV_KeyDown;
  event.data1 = (short) keyCode;
  NSLog(@"keyDown: code: %li", (long)keyCode);
  
  if (guiCapture) {
    NSLog(@"GUI Capture is On!");
    event.type = EV_GUI_Event;
    event.subtype = EV_GUI_KeyDown;
    BOOL isAsciiKey = NO;
    switch (keyCode) {
      case DIK_UP:
        event.data1 = GK_UP;
        break;
      case DIK_DOWN:
        event.data1 = GK_DOWN;
        break;
      case DIK_LEFT:
        event.data1 = GK_LEFT;
        break;
      case DIK_RIGHT:
        event.data1 = GK_RIGHT;
        break;
      case DIK_RETURN:
        event.data1 = GK_RETURN;
        break;
      case DIK_ESCAPE:
        event.data1 = GK_ESCAPE;
        break;
      case DIK_F1:
        event.data1 = GK_F1;
        break;
      case DIK_DELETE:
        event.data1 = GK_BACKSPACE;
        break;
      default:
        short keyCodeShort = (short) keyCode;
        NSNumber *asciiNumber = (NSNumber*) [[self dikToAsciiMap] objectForKey:@(keyCodeShort)];
        if (asciiNumber != nil) {
          unsigned char ascii = [asciiNumber unsignedCharValue];
          NSLog(@"Found ascii %c (%hhd) for %li", ascii, ascii, (long)keyCodeShort);
          event.data1 = ascii;
          isAsciiKey = YES;
        }
        break;
    }
    if (event.data1 < 128 && isAsciiKey) {
      event.data1 = toupper(event.data1);
      //            event.data2 = 97; // testing..a - don't need to set this
//      NSLog(@"keydown: posting gui key event for key %@, event.data1 = %i",key.keyLabel, event.data1);
      D_PostEvent(&event);
      // need to set this to output to console gui - looks like it needs to be the system character (utf-16?)
      unichar realchar = [label characterAtIndex:0];
      if (keyCode == DIK_SPACE) {
        realchar = ' ';
      }
      event.subtype = EV_GUI_Char;
      event.data1   = realchar;
      event.data2   = 0;
      D_PostEvent(&event);
      return;
    }
  }
  D_PostEvent(&event);
}

- (void)keyDown:(id<KeyCoded> _Nonnull)key {
  [self keyDownInternal:key.keyCode label:key.keyLabel];
}

- (void)keyUpInternal:(NSInteger)keyCode {
  event_t event = {};
  event.type = EV_KeyUp;
  event.data1 = (short) keyCode;
  NSLog(@"keyUp: code: %li", (long)keyCode);
  if (guiCapture) {
      NSLog(@"GUI Capture is On!");
      event.type = EV_GUI_Event;
      event.subtype = EV_GUI_KeyUp;
      switch (keyCode) {
          case DIK_UP:
              event.data1 = GK_UP;
              break;
          case DIK_DOWN:
              event.data1 = GK_DOWN;
              break;
          case DIK_LEFT:
              event.data1 = GK_LEFT;
              break;
          case DIK_RIGHT:
              event.data1 = GK_RIGHT;
              break;
          case DIK_RETURN:
              event.data1 = GK_RETURN;
              break;
          case DIK_ESCAPE:
              event.data1 = GK_ESCAPE;
              break;
          case DIK_F1:
              event.data1 = GK_F1;
              break;
          case DIK_DELETE:
              event.data1 = GK_BACKSPACE;
              break;
          default:
              short keyCodeShort = (short) keyCode;
              NSNumber *asciiNumber = (NSNumber*) [[self dikToAsciiMap] objectForKey:@(keyCodeShort)];
              if (asciiNumber != nil) {
                  unsigned char ascii = [asciiNumber unsignedCharValue];
                  NSLog(@"Found ascii %c (%hhd) for %li", ascii, ascii, (long)keyCodeShort);
                  event.data1 = ascii;
              }
              break;
      }
      if (event.data1 < 128) {
          event.data1 = toupper(event.data1);
          event.data2 = 97; // testing..a
//          NSLog(@"keyUp: posting gui key event for key %@, event.data1 keyCode= %i",key.keyLabel, event.data1);
          D_PostEvent(&event);
          return;
      }
  }
  D_PostEvent(&event);
}

- (void)keyUp:(id<KeyCoded> _Nonnull)key {
  [self keyUpInternal:key.keyCode];
}

-(void)mouseMoveWithX:(NSInteger)x Y:(NSInteger)y {
  PostMouseMove((int)x, (int)y);
}

-(void)handleLeftThumbstickDirectionalInput:(ThumbstickDirection)direction isPressed:(BOOL)isPressed {
  event_t event = {};
  int16_t data1 = 0;
  switch (direction) {
    case ThumbstickDirectionUp:
      data1 = KEY_PAD_LTHUMB_UP;
      break;
    
    case ThumbstickDirectionDown:
      data1 = KEY_PAD_LTHUMB_DOWN;
      break;
      
    case ThumbstickDirectionLeft:
      data1 = KEY_PAD_LTHUMB_LEFT;
      break;
    
    case ThumbstickDirectionRight:
      data1 = KEY_PAD_LTHUMB_RIGHT;
      break;
  }
  event.type = isPressed ? EV_KeyDown : EV_KeyUp;
  event.data1 = data1;
  D_PostEvent(&event);
}

-(void)handleGameControl:(GamepadControl)gamepadControl isPressed:(BOOL)isPressed {
  event_t event = {};
  int16_t data1 = 0;
  if (gamepadControl == GamepadControlA) {
    data1 = KEY_PAD_A;
  } else if (gamepadControl == GamepadControlB) {
    data1 = KEY_PAD_B;
  } else if (gamepadControl == GamepadControlX) {
    data1 = KEY_PAD_X;
  } else if (gamepadControl == GamepadControlY) {
    data1 = KEY_PAD_Y;
  } else if (gamepadControl == GamepadControlL) {
    data1 = KEY_PAD_LSHOULDER;
  } else if (gamepadControl == GamepadControlR) {
    data1 = KEY_PAD_RSHOULDER;
  } else if (gamepadControl == GamepadControlRT) {
    data1 = KEY_PAD_RTRIGGER;
  } else if (gamepadControl == GamepadControlLT) {
    data1 = KEY_PAD_LTRIGGER;
  } else if (gamepadControl == GamepadControlSelect) {
    data1 = KEY_PAD_BACK;
  } else if (gamepadControl == GamepadControlStart) {
    data1 = KEY_PAD_START;
  } else if (gamepadControl == GamepadControlLS) {
    data1 = KEY_PAD_LTHUMB;
  } else if (gamepadControl == GamepadControlRS) {
    data1 = KEY_PAD_RTHUMB;
  } else if (gamepadControl == GamepadControlLeftMouseClick) {
    data1 = KEY_MOUSE1;
  } else if (gamepadControl == GamepadControlRightMouseClick) {
    data1 = KEY_MOUSE2;
  }
  if (data1 == 0) { return; }
  event.type = isPressed ? EV_KeyDown : EV_KeyUp;
  event.data1 = data1;
  D_PostEvent(&event);
}

-(void)handleGameControllerInputForGamepad:(GCExtendedGamepad*)gamepad button:(GCControllerButtonInput*)button isPressed:(BOOL)isPressed {
  event_t event = {};
  int16_t data1 = 0;
  if (button == gamepad.buttonA) {
    data1 = KEY_PAD_A;
  } else if (button == gamepad.buttonB) {
    data1 = KEY_PAD_B;
  } else if (button == gamepad.buttonX) {
    data1 = KEY_PAD_X;
  } else if (button == gamepad.buttonY) {
    data1 = KEY_PAD_Y;
  } else if (button == gamepad.leftShoulder) {
    data1 = KEY_PAD_LSHOULDER;
  } else if (button == gamepad.rightShoulder) {
    data1 = KEY_PAD_RSHOULDER;
  } else if (button == gamepad.rightTrigger) {
    data1 = KEY_PAD_RTRIGGER;
  } else if (button == gamepad.leftTrigger) {
    data1 = KEY_PAD_LTRIGGER;
  } else if (button == gamepad.dpad.up) {
    data1 = KEY_PAD_DPAD_UP;
  } else if (button == gamepad.dpad.down) {
    data1 = KEY_PAD_DPAD_DOWN;
  } else if (button == gamepad.dpad.left) {
    data1 = KEY_PAD_DPAD_LEFT;
  } else if (button == gamepad.dpad.right) {
    data1 = KEY_PAD_DPAD_RIGHT;
  } else if (button == gamepad.buttonOptions) {
    data1 = KEY_PAD_BACK;
  } else if (button == gamepad.buttonMenu) {
    data1 = KEY_PAD_START;
  } else if (button == gamepad.leftThumbstickButton) {
    data1 = KEY_PAD_LTHUMB;
  } else if (button == gamepad.rightThumbstickButton) {
    data1 = KEY_PAD_RTHUMB;
  }
  if (data1 == 0) { return; }
  event.type = isPressed ? EV_KeyDown : EV_KeyUp;
  event.data1 = data1;
  D_PostEvent(&event);
}

-(void)handleOverlayDPadWithDirection:(DPadDirection)direction {
  event_t event = {};
  int16_t data1 = 0;
  
  if (direction == DPadDirectionNone) {
    event.type = EV_KeyUp;
    event.data1 = KEY_PAD_DPAD_UP;
    D_PostEvent(&event);
    event.data1 = KEY_PAD_DPAD_LEFT;
    
    D_PostEvent(&event);
    event.data1 = KEY_PAD_DPAD_RIGHT;
    D_PostEvent(&event);
    event.data1 = KEY_PAD_DPAD_DOWN;
    D_PostEvent(&event);
    return;
  }
  
  if (direction == DPadDirectionUp) {
    data1 = KEY_PAD_DPAD_UP;
  } else if (direction == DPadDirectionLeft) {
    data1 = KEY_PAD_DPAD_LEFT;
  } else if (direction == DPadDirectionRight) {
    data1 = KEY_PAD_DPAD_RIGHT;
  } else if (direction == DPadDirectionDown) {
    data1 = KEY_PAD_DPAD_DOWN;
  }
  if (data1 == 0) { return; }
  event.type = EV_KeyDown;
  event.data1 = data1;
  D_PostEvent(&event);
}

-(void)handleGamepadWithJoyButton:(NSInteger)number isPressed:(BOOL)isPressed {
  event_t event = {};
  event.type = isPressed ? EV_KeyDown : EV_KeyUp;
  event.data1 = KEY_FIRSTJOYBUTTON + number;
  if (event.data1 != 0) {
    D_PostEvent(&event);
  }
}

-(void)handleOverlayButtonName:(NSString*)buttonName isPressed:(BOOL)isPressed {
  NSInteger keyCode = NSNotFound;
  if ([buttonName isEqualToString:[EmulatorKeyboardController escButtonName]]) {
    keyCode = DIK_ESCAPE;
  }
  if (keyCode == NSNotFound) {
    return;
  }
  if (isPressed) {
    [self keyDownInternal:keyCode label:buttonName];
  } else {
    [self keyUpInternal:keyCode];
  }
}

-(void)handleLeftMouseButtonWithPressed:(BOOL)isPressed {
  event_t event = {};
  event.type = isPressed ? EV_KeyDown : EV_KeyUp;
  event.data1 = KEY_MOUSE1;
  D_PostEvent(&event);
}

@end

