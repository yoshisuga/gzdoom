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
#include "m_joy.h"
//#if TARGET_OS_TV
//#include "dikeys.h"
//#endif

int GameMain();
FArgs *args;

void ios_get_base_path(char *path) {
    NSArray *paths;
    NSString *DocumentsDirPath;
    
#if TARGET_OS_IOS
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentsDirPath = [paths objectAtIndex:0];
#elif TARGET_OS_TV
  paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  DocumentsDirPath = [paths objectAtIndex:0];
#endif
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
  
#if TARGET_OS_IOS
  EmulatorKeyboardController *keyboardController = [[EmulatorKeyboardController alloc] initWithLeftKeyboardModel:iosUtils.leftKeyboardModel rightKeyboardModel:iosUtils.rightKeyboardModel];
  keyboardController.rightKeyboardModel.delegate = (id<EmulatorKeyboardKeyPressedDelegate>)iosUtils;
  keyboardController.leftKeyboardModel.delegate = (id<EmulatorKeyboardKeyPressedDelegate>)iosUtils;
  keyboardController.rightKeyboardModel.modifierDelegate = (id<EmulatorKeyboardModifierPressedDelegate>)iosUtils;
  keyboardController.leftKeyboardModel.modifierDelegate = (id<EmulatorKeyboardModifierPressedDelegate>)iosUtils;
  [rootVC addChildViewController:keyboardController];
  [keyboardController didMoveToParentViewController:rootVC];
  keyboardController.view.translatesAutoresizingMaskIntoConstraints = NO;
  [rootVC.view addSubview:keyboardController.view];
  [[keyboardController.view.leadingAnchor constraintEqualToAnchor:rootVC.view.leadingAnchor] setActive:YES];
  [[keyboardController.view.trailingAnchor constraintEqualToAnchor:rootVC.view.trailingAnchor] setActive:YES];
  [[keyboardController.view.topAnchor constraintEqualToAnchor:rootVC.view.topAnchor] setActive:YES];
  [[keyboardController.view.bottomAnchor constraintEqualToAnchor:rootVC.view.bottomAnchor] setActive:YES];
#elif TARGET_OS_TV
  [GameControllerHandler shared];
  [[TVOSUIHandler shared] setRootViewController:rootVC];
#endif
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

void IOS_HandleJoystickAxes(float axes[NUM_JOYAXIS]) {
  axes[JOYAXIS_Forward] = [JoystickInputHolder shared].axisY * -1.0;  
  axes[JOYAXIS_Side] = [JoystickInputHolder shared].axisX * (guiCapture ? 1 : -1.0);
  
  // translate axis values to button states - might be for directional input for menu?
  uint8_t buttonstate = Joy_XYAxesToButtons(axes[JOYAXIS_Side], [JoystickInputHolder shared].axisY);
  Joy_GenerateButtonEvents([JoystickInputHolder shared].buttonState, buttonstate, 4, KEY_JOYAXIS1PLUS);
  [JoystickInputHolder shared].buttonState = buttonstate;
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

int16_t IOS_GetAsciiFromSDLKeyCode(SDL_Keycode keyCode) {
  NSDictionary *sdlKeyCodeToAsciiMap = @{
    @(SDLK_1) : [NSNumber numberWithUnsignedChar:'1'],
    @(SDLK_2) : [NSNumber numberWithUnsignedChar:'2'],
    @(SDLK_3) : [NSNumber numberWithUnsignedChar:'3'],
    @(SDLK_4) : [NSNumber numberWithUnsignedChar:'4'],
    @(SDLK_5) : [NSNumber numberWithUnsignedChar:'5'],
    @(SDLK_6) : [NSNumber numberWithUnsignedChar:'6'],
    @(SDLK_7) : [NSNumber numberWithUnsignedChar:'7'],
    @(SDLK_8) : [NSNumber numberWithUnsignedChar:'8'],
    @(SDLK_9) : [NSNumber numberWithUnsignedChar:'9'],
    @(SDLK_0) : [NSNumber numberWithUnsignedChar:'0'],
    @(SDLK_a) : [NSNumber numberWithUnsignedChar:'a'],
    @(SDLK_b) : [NSNumber numberWithUnsignedChar:'b'],
    @(SDLK_c) : [NSNumber numberWithUnsignedChar:'c'],
    @(SDLK_d) : [NSNumber numberWithUnsignedChar:'d'],
    @(SDLK_e) : [NSNumber numberWithUnsignedChar:'e'],
    @(SDLK_f) : [NSNumber numberWithUnsignedChar:'f'],
    @(SDLK_g) : [NSNumber numberWithUnsignedChar:'g'],
    @(SDLK_h) : [NSNumber numberWithUnsignedChar:'h'],
    @(SDLK_i) : [NSNumber numberWithUnsignedChar:'i'],
    @(SDLK_j) : [NSNumber numberWithUnsignedChar:'j'],
    @(SDLK_k) : [NSNumber numberWithUnsignedChar:'k'],
    @(SDLK_l) : [NSNumber numberWithUnsignedChar:'l'],
    @(SDLK_m) : [NSNumber numberWithUnsignedChar:'m'],
    @(SDLK_n) : [NSNumber numberWithUnsignedChar:'n'],
    @(SDLK_o) : [NSNumber numberWithUnsignedChar:'o'],
    @(SDLK_p) : [NSNumber numberWithUnsignedChar:'p'],
    @(SDLK_q) : [NSNumber numberWithUnsignedChar:'q'],
    @(SDLK_r) : [NSNumber numberWithUnsignedChar:'r'],
    @(SDLK_s) : [NSNumber numberWithUnsignedChar:'s'],
    @(SDLK_t) : [NSNumber numberWithUnsignedChar:'t'],
    @(SDLK_u) : [NSNumber numberWithUnsignedChar:'u'],
    @(SDLK_v) : [NSNumber numberWithUnsignedChar:'v'],
    @(SDLK_w) : [NSNumber numberWithUnsignedChar:'w'],
    @(SDLK_x) : [NSNumber numberWithUnsignedChar:'x'],
    @(SDLK_y) : [NSNumber numberWithUnsignedChar:'y'],
    @(SDLK_z) : [NSNumber numberWithUnsignedChar:'z'],
    @(SDLK_MINUS) : [NSNumber numberWithUnsignedChar:'-'],
    @(SDLK_EQUALS) : [NSNumber numberWithUnsignedChar:'='],
    @(SDLK_PERIOD) : [NSNumber numberWithUnsignedChar:'.'],
    @(SDLK_COMMA) : [NSNumber numberWithUnsignedChar:','],
    @(SDLK_SEMICOLON) : [NSNumber numberWithUnsignedChar:';'],
    @(SDLK_SPACE) : [NSNumber numberWithUnsignedChar:' '],
    @(SDLK_QUOTE) : [NSNumber numberWithUnsignedChar:'\''],
    @(SDLK_UNDERSCORE) : [NSNumber numberWithUnsignedChar:'_'],
  };
  NSNumber *asciiNumber = (NSNumber*) [sdlKeyCodeToAsciiMap objectForKey:@(keyCode)];
  return asciiNumber != nil ? [asciiNumber unsignedCharValue] : 0;
}

const UInt8 DIK_TO_ASCII[128] =
{
    DIK_A, DIK_S, DIK_D, DIK_F, DIK_H, DIK_G, DIK_Z, DIK_X,
    DIK_C, DIK_V, 0, DIK_B, DIK_Q
};

#if TARGET_OS_IOS
@interface IOSUtils()<EmulatorKeyboardKeyPressedDelegate, EmulatorKeyboardModifierPressedDelegate>

@property(nonatomic, strong) NSMutableSet<NSNumber*> *modifiersPressed;
#else
@interface IOSUtils()
#endif
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
#if TARGET_OS_IOS
  _modifiersPressed = [[NSMutableSet<NSNumber*> alloc] init];
#endif
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
      case DIK_BACK:
        event.data1 = GK_BACKSPACE;
        break;
      case DIK_PRIOR:
        event.data1 = GK_PGUP;
        break;
      case DIK_NEXT:
        event.data1 = GK_PGDN;
        break;
      case DIK_HOME:
        event.data1 = GK_HOME;
        break;
      case DIK_END:
        event.data1 = GK_END;
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

      BOOL isShiftDown = NO;
#if TARGET_IS_IOS
      // Deal with modifiers
      isShiftDown = [self.modifiersPressed containsObject:@(DIK_LSHIFT)];
      BOOL isCtrlDown = [self.modifiersPressed containsObject:@(DIK_LCONTROL)];
      BOOL isAltDown = [self.modifiersPressed containsObject:@(DIK_LMENU)];
      event.data3 = (isShiftDown ? GKM_SHIFT : 0) |
                    (isCtrlDown ? GKM_CTRL : 0) |
                    (isAltDown ? GKM_ALT : 0);
#endif

      event.data1 = toupper(event.data1);
      //            event.data2 = 97; // testing..a - don't need to set this
//      NSLog(@"keydown: posting gui key event for key %@, event.data1 = %i",key.keyLabel, event.data1);
      D_PostEvent(&event);
      // need to set this to output to console gui - looks like it needs to be the system character (utf-16?)
      unichar realchar = [label characterAtIndex:0];
      if (keyCode == DIK_SPACE) {
        realchar = ' ';
      } else if (isShiftDown) {
        if (keyCode == DIK_MINUS) {
          realchar = '_';
        } else if (keyCode == DIK_EQUALS) {
          realchar = '+';
        } else if (keyCode == DIK_APOSTROPHE) {
          realchar = '"';
        } else if (keyCode == DIK_1) {
          realchar = '!';
        } else if (keyCode == DIK_2) {
          realchar = '@';
        } else if (keyCode == DIK_3) {
          realchar = '#';
        } else if (keyCode == DIK_4) {
          realchar = '$';
        } else if (keyCode == DIK_5) {
          realchar = '%';
        } else if (keyCode == DIK_6) {
          realchar = '^';
        } else if (keyCode == DIK_7) {
          realchar = '&';
        } else if (keyCode == DIK_8) {
          realchar = '*';
        } else if (keyCode == DIK_9) {
          realchar = '(';
        } else if (keyCode == DIK_0) {
          realchar = ')';
        } else if (keyCode == DIK_LBRACKET) {
          realchar = '{';
        } else if (keyCode == DIK_RBRACKET) {
          realchar = '}';
        } else if (keyCode == DIK_BACKSLASH) {
          realchar = '|';
        } else if (keyCode == DIK_SEMICOLON) {
          realchar = ':';
        } else if (keyCode == DIK_COMMA) {
          realchar = '<';
        } else if (keyCode == DIK_PERIOD) {
          realchar = '>';
        } else if (keyCode == DIK_SLASH) {
          realchar = '?';
        } else {
          realchar = toupper(realchar);
        }
      }
      event.subtype = EV_GUI_Char;
      event.data1   =  realchar;
      event.data2   = 0;
      
      NSLog(@"Posting GUI Capture key: data1 = %c data3 = %i", event.data1, event.data3);
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
  } else if (gamepadControl == GamepadControlKB_Esc) {
    if (isPressed) {
      [self keyDownInternal:DIK_ESCAPE label:@"ESC"];
    } else {
      [self keyUpInternal:DIK_ESCAPE];
    }
  } else if (gamepadControl == GamepadControlKB_F1) {
    if (isPressed) {
      [self keyDownInternal:DIK_F1 label:@"F1"];
    } else {
      [self keyUpInternal:DIK_F1];
    }
  } else if (gamepadControl == GamepadControlKB_F2) {
    if (isPressed) {
      [self keyDownInternal:DIK_F2 label:@"F2"];
    } else {
      [self keyUpInternal:DIK_F2];
    }
  } else if (gamepadControl == GamepadControlKB_F3) {
    if (isPressed) {
      [self keyDownInternal:DIK_F3 label:@"F3"];
    } else {
      [self keyUpInternal:DIK_F3];
    }
  } else if (gamepadControl == GamepadControlKB_F4) {
    if (isPressed) {
      [self keyDownInternal:DIK_F3 label:@"F4"];
    } else {
      [self keyUpInternal:DIK_F4];
    }
  } else if (gamepadControl == GamepadControlKB_F5) {
    if (isPressed) {
      [self keyDownInternal:DIK_F5 label:@"F5"];
    } else {
      [self keyUpInternal:DIK_F5];
    }
  } else if (gamepadControl == GamepadControlKB_F6) {
    if (isPressed) {
      [self keyDownInternal:DIK_F6 label:@"F6"];
    } else {
      [self keyUpInternal:DIK_F6];
    }
  } else if (gamepadControl == GamepadControlKB_F7) {
    if (isPressed) {
      [self keyDownInternal:DIK_F7 label:@"F7"];
    } else {
      [self keyUpInternal:DIK_F7];
    }
  } else if (gamepadControl == GamepadControlKB_F8) {
    if (isPressed) {
      [self keyDownInternal:DIK_F8 label:@"F8"];
    } else {
      [self keyUpInternal:DIK_F8];
    }
  } else if (gamepadControl == GamepadControlKB_F9) {
    if (isPressed) {
      [self keyDownInternal:DIK_F9 label:@"F9"];
    } else {
      [self keyUpInternal:DIK_F9];
    }
  } else if (gamepadControl == GamepadControlKB_F10) {
    if (isPressed) {
      [self keyDownInternal:DIK_F10 label:@"F10"];
    } else {
      [self keyUpInternal:DIK_F10];
    }
  } else if (gamepadControl == GamepadControlKB_F11) {
    if (isPressed) {
      [self keyDownInternal:DIK_F11 label:@"F11"];
    } else {
      [self keyUpInternal:DIK_F11];
    }
  } else if (gamepadControl == GamepadControlKB_F12) {
    if (isPressed) {
      [self keyDownInternal:DIK_F12 label:@"F12"];
    } else {
      [self keyUpInternal:DIK_F12];
    }
  } else if (gamepadControl == GamepadControlKB_1) {
    if (isPressed) {
      [self keyDownInternal:DIK_1 label:@"1"];
    } else {
      [self keyUpInternal:DIK_1];
    }
  } else if (gamepadControl == GamepadControlKB_2) {
    if (isPressed) {
      [self keyDownInternal:DIK_2 label:@"2"];
    } else {
      [self keyUpInternal:DIK_2];
    }
  } else if (gamepadControl == GamepadControlKB_3) {
    if (isPressed) {
      [self keyDownInternal:DIK_3 label:@"3"];
    } else {
      [self keyUpInternal:DIK_3];
    }
  } else if (gamepadControl == GamepadControlKB_4) {
    if (isPressed) {
      [self keyDownInternal:DIK_4 label:@"4"];
    } else {
      [self keyUpInternal:DIK_4];
    }
  } else if (gamepadControl == GamepadControlKB_5) {
    if (isPressed) {
      [self keyDownInternal:DIK_5 label:@"5"];
    } else {
      [self keyUpInternal:DIK_5];
    }
  } else if (gamepadControl == GamepadControlKB_6) {
    if (isPressed) {
      [self keyDownInternal:DIK_6 label:@"6"];
    } else {
      [self keyUpInternal:DIK_6];
    }
  } else if (gamepadControl == GamepadControlKB_7) {
    if (isPressed) {
      [self keyDownInternal:DIK_7 label:@"7"];
    } else {
      [self keyUpInternal:DIK_8];
    }
  } else if (gamepadControl == GamepadControlKB_8) {
    if (isPressed) {
      [self keyDownInternal:DIK_8 label:@"8"];
    } else {
      [self keyUpInternal:DIK_8];
    }
  } else if (gamepadControl == GamepadControlKB_9) {
    if (isPressed) {
      [self keyDownInternal:DIK_9 label:@"9"];
    } else {
      [self keyUpInternal:DIK_9];
    }
  } else if (gamepadControl == GamepadControlKB_0) {
    if (isPressed) {
      [self keyDownInternal:DIK_0 label:@"0"];
    } else {
      [self keyUpInternal:DIK_0];
    }
  } else if (gamepadControl == GamepadControlKB_Minus) {
    if (isPressed) {
      [self keyDownInternal:DIK_MINUS label:@"-"];
    } else {
      [self keyUpInternal:DIK_MINUS];
    }
  } else if (gamepadControl == GamepadControlKB_Equal) {
    if (isPressed) {
      [self keyDownInternal:DIK_EQUALS label:@"="];
    } else {
      [self keyUpInternal:DIK_EQUALS];
    }
  } else if (gamepadControl == GamepadControlKB_Backspace) {
    if (isPressed) {
      [self keyDownInternal:DIK_BACK label:@"BSP"];
    } else {
      [self keyUpInternal:DIK_BACK];
    }
  } else if (gamepadControl == GamepadControlKB_Tab) {
    if (isPressed) {
      [self keyDownInternal:DIK_TAB label:@"TAB"];
    } else {
      [self keyUpInternal:DIK_TAB];
    }
  } else if (gamepadControl == GamepadControlKB_Q) {
    if (isPressed) {
      [self keyDownInternal:DIK_Q label:@"Q"];
    } else {
      [self keyUpInternal:DIK_Q];
    }
  } else if (gamepadControl == GamepadControlKB_W) {
    if (isPressed) {
      [self keyDownInternal:DIK_W label:@"W"];
    } else {
      [self keyUpInternal:DIK_W];
    }
  } else if (gamepadControl == GamepadControlKB_E) {
    if (isPressed) {
      [self keyDownInternal:DIK_E label:@"E"];
    } else {
      [self keyUpInternal:DIK_E];
    }
  } else if (gamepadControl == GamepadControlKB_R) {
    if (isPressed) {
      [self keyDownInternal:DIK_R label:@"R"];
    } else {
      [self keyUpInternal:DIK_R];
    }
  } else if (gamepadControl == GamepadControlKB_T) {
    if (isPressed) {
      [self keyDownInternal:DIK_T label:@"T"];
    } else {
      [self keyUpInternal:DIK_T];
    }
  } else if (gamepadControl == GamepadControlKB_Y) {
    if (isPressed) {
      [self keyDownInternal:DIK_Y label:@"Y"];
    } else {
      [self keyUpInternal:DIK_Y];
    }
  } else if (gamepadControl == GamepadControlKB_U) {
    if (isPressed) {
      [self keyDownInternal:DIK_U label:@"U"];
    } else {
      [self keyUpInternal:DIK_U];
    }
  } else if (gamepadControl == GamepadControlKB_I) {
    if (isPressed) {
      [self keyDownInternal:DIK_I label:@"I"];
    } else {
      [self keyUpInternal:DIK_I];
    }
  } else if (gamepadControl == GamepadControlKB_O) {
    if (isPressed) {
      [self keyDownInternal:DIK_O label:@"O"];
    } else {
      [self keyUpInternal:DIK_O];
    }
  } else if (gamepadControl == GamepadControlKB_P) {
    if (isPressed) {
      [self keyDownInternal:DIK_P label:@"P"];
    } else {
      [self keyUpInternal:DIK_P];
    }
  } else if (gamepadControl == GamepadControlKB_RightBracket) {
    if (isPressed) {
      [self keyDownInternal:DIK_RBRACKET label:@"]"];
    } else {
      [self keyUpInternal:DIK_RBRACKET];
    }
  } else if (gamepadControl == GamepadControlKB_LeftBracket) {
    if (isPressed) {
      [self keyDownInternal:DIK_LBRACKET label:@"["];
    } else {
      [self keyUpInternal:DIK_LBRACKET];
    }
  } else if (gamepadControl == GamepadControlKB_Backslash) {
    if (isPressed) {
      [self keyDownInternal:DIK_BACKSLASH label:@"\\"];
    } else {
      [self keyUpInternal:DIK_BACKSLASH];
    }
  } else if (gamepadControl == GamepadControlKB_A) {
    if (isPressed) {
      [self keyDownInternal:DIK_A label:@"A"];
    } else {
      [self keyUpInternal:DIK_A];
    }
  } else if (gamepadControl == GamepadControlKB_S) {
    if (isPressed) {
      [self keyDownInternal:DIK_S label:@"S"];
    } else {
      [self keyUpInternal:DIK_S];
    }
  } else if (gamepadControl == GamepadControlKB_D) {
    if (isPressed) {
      [self keyDownInternal:DIK_D label:@"D"];
    } else {
      [self keyUpInternal:DIK_D];
    }
  } else if (gamepadControl == GamepadControlKB_F) {
    if (isPressed) {
      [self keyDownInternal:DIK_F label:@"F"];
    } else {
      [self keyUpInternal:DIK_F];
    }
  } else if (gamepadControl == GamepadControlKB_G) {
    if (isPressed) {
      [self keyDownInternal:DIK_G label:@"G"];
    } else {
      [self keyUpInternal:DIK_G];
    }
  } else if (gamepadControl == GamepadControlKB_H) {
    if (isPressed) {
      [self keyDownInternal:DIK_H label:@"H"];
    } else {
      [self keyUpInternal:DIK_H];
    }
  } else if (gamepadControl == GamepadControlKB_J) {
    if (isPressed) {
      [self keyDownInternal:DIK_J label:@"J"];
    } else {
      [self keyUpInternal:DIK_J];
    }
  } else if (gamepadControl == GamepadControlKB_K) {
    if (isPressed) {
      [self keyDownInternal:DIK_K label:@"D"];
    } else {
      [self keyUpInternal:DIK_K];
    }
  } else if (gamepadControl == GamepadControlKB_L) {
    if (isPressed) {
      [self keyDownInternal:DIK_L label:@"L"];
    } else {
      [self keyUpInternal:DIK_L];
    }
  } else if (gamepadControl == GamepadControlKB_Semicolon) {
    if (isPressed) {
      [self keyDownInternal:DIK_SEMICOLON label:@";"];
    } else {
      [self keyUpInternal:DIK_SEMICOLON];
    }
  } else if (gamepadControl == GamepadControlKB_Quote) {
    if (isPressed) {
      [self keyDownInternal:DIK_APOSTROPHE label:@"'"];
    } else {
      [self keyUpInternal:DIK_APOSTROPHE];
    }
  } else if (gamepadControl == GamepadControlKB_Return) {
    if (isPressed) {
      [self keyDownInternal:DIK_RETURN label:@"R"];
    } else {
      [self keyUpInternal:DIK_RETURN];
    }
  } else if (gamepadControl == GamepadControlKB_Shift) {
    if (isPressed) {
      [self keyDownInternal:DIK_LSHIFT label:@"SHIFT"];
    } else {
      [self keyUpInternal:DIK_LSHIFT];
    }
  } else if (gamepadControl == GamepadControlKB_Z) {
    if (isPressed) {
      [self keyDownInternal:DIK_Z label:@"Z"];
    } else {
      [self keyUpInternal:DIK_Z];
    }
  } else if (gamepadControl == GamepadControlKB_X) {
    if (isPressed) {
      [self keyDownInternal:DIK_X label:@"X"];
    } else {
      [self keyUpInternal:DIK_X];
    }
  } else if (gamepadControl == GamepadControlKB_C) {
    if (isPressed) {
      [self keyDownInternal:DIK_C label:@"C"];
    } else {
      [self keyUpInternal:DIK_C];
    }
  } else if (gamepadControl == GamepadControlKB_D) {
    if (isPressed) {
      [self keyDownInternal:DIK_V label:@"V"];
    } else {
      [self keyUpInternal:DIK_V];
    }
  } else if (gamepadControl == GamepadControlKB_D) {
    if (isPressed) {
      [self keyDownInternal:DIK_B label:@"B"];
    } else {
      [self keyUpInternal:DIK_B];
    }
  } else if (gamepadControl == GamepadControlKB_N) {
    if (isPressed) {
      [self keyDownInternal:DIK_N label:@"N"];
    } else {
      [self keyUpInternal:DIK_N];
    }
  } else if (gamepadControl == GamepadControlKB_D) {
    if (isPressed) {
      [self keyDownInternal:DIK_M label:@"M"];
    } else {
      [self keyUpInternal:DIK_M];
    }
  } else if (gamepadControl == GamepadControlKB_Comma) {
    if (isPressed) {
      [self keyDownInternal:DIK_COMMA label:@","];
    } else {
      [self keyUpInternal:DIK_COMMA];
    }
  } else if (gamepadControl == GamepadControlKB_Period) {
    if (isPressed) {
      [self keyDownInternal:DIK_PERIOD label:@"."];
    } else {
      [self keyUpInternal:DIK_PERIOD];
    }
  } else if (gamepadControl == GamepadControlKB_Slash) {
    if (isPressed) {
      [self keyDownInternal:DIK_SLASH label:@"/"];
    } else {
      [self keyUpInternal:DIK_SLASH];
    }
  } else if (gamepadControl == GamepadControlKB_Control) {
    if (isPressed) {
      [self keyDownInternal:DIK_LCONTROL label:@"CTRL"];
    } else {
      [self keyUpInternal:DIK_LCONTROL];
    }
  } else if (gamepadControl == GamepadControlKB_Alt) {
    if (isPressed) {
      [self keyDownInternal:DIK_LMENU label:@"ALT"];
    } else {
      [self keyUpInternal:DIK_LMENU];
    }
  } else if (gamepadControl == GamepadControlKB_Space) {
    if (isPressed) {
      [self keyDownInternal:DIK_SPACE label:@" "];
    } else {
      [self keyUpInternal:DIK_SPACE];
    }
  } else if (gamepadControl == GamepadControlKB_Up) {
    if (isPressed) {
      [self keyDownInternal:DIK_UP label:@"UP"];
    } else {
      [self keyUpInternal:DIK_UP];
    }
  } else if (gamepadControl == GamepadControlKB_Down) {
    if (isPressed) {
      [self keyDownInternal:DIK_DOWN label:@"DWN"];
    } else {
      [self keyUpInternal:DIK_DOWN];
    }
  } else if (gamepadControl == GamepadControlKB_Left) {
    if (isPressed) {
      [self keyDownInternal:DIK_LEFT label:@"LFT"];
    } else {
      [self keyUpInternal:DIK_LEFT];
    }
  } else if (gamepadControl == GamepadControlKB_Right) {
    if (isPressed) {
      [self keyDownInternal:DIK_RIGHT label:@"RGT"];
    } else {
      [self keyUpInternal:DIK_RIGHT];
    }
  } else if (gamepadControl == GamepadControlKB_Home) {
    if (isPressed) {
      [self keyDownInternal:DIK_HOME label:@"HME"];
    } else {
      [self keyUpInternal:DIK_HOME];
    }
  } else if (gamepadControl == GamepadControlKB_Insert) {
    if (isPressed) {
      [self keyDownInternal:DIK_INSERT label:@"INS"];
    } else {
      [self keyUpInternal:DIK_INSERT];
    }
  } else if (gamepadControl == GamepadControlKB_Del) {
    if (isPressed) {
      [self keyDownInternal:DIK_DELETE label:@"DEL"];
    } else {
      [self keyUpInternal:DIK_DELETE];
    }
  } else if (gamepadControl == GamepadControlKB_End) {
    if (isPressed) {
      [self keyDownInternal:DIK_END label:@"END"];
    } else {
      [self keyUpInternal:DIK_END];
    }
  } else if (gamepadControl == GamepadControlKB_PageUp) {
    if (isPressed) {
      [self keyDownInternal:DIK_PRIOR label:@"PU"];
    } else {
      [self keyUpInternal:DIK_PRIOR];
    }
  } else if (gamepadControl == GamepadControlKB_PageDown) {
    if (isPressed) {
      [self keyDownInternal:DIK_NEXT label:@"PD"];
    } else {
      [self keyUpInternal:DIK_NEXT];
    }
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
  [[NSNotificationCenter defaultCenter] postNotificationName:[GZDNotificationName gameControllerDidInput] object:nil];
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

#if TARGET_OS_IOS
#pragma mark EmulatorKeyboardModifierPressedDelegate
- (BOOL)isModifierEnabledWithKey:(id<KeyCoded> _Nonnull)key {
  return [self.modifiersPressed containsObject:@(key.keyCode)];
}

- (void)modifierPressedWithKey:(id<KeyCoded> _Nonnull)key enable:(BOOL)enable { 
  if (enable) {
    [self keyDown:key];
    [self.modifiersPressed addObject:@(key.keyCode)];
  } else {
    [self keyUp:key];
    [self.modifiersPressed removeObject:@(key.keyCode)];
  }
}
#endif
@end
