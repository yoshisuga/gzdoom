//
//  IOSUtils.m
//  xm8-ios
//
//  Created by Yoshi Sugawara on 12/12/16.
//
//

#import "IOSUtils.h"
#import <UIKit/UIKit.h>

#import "gzdoom-Swift.h"

#include "ios-glue.h"
#include "video-hook.h"
#include "SDL_syswm.h"
#include "d_eventbase.h"
#include "ios-input-hook.h"

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
}

bool guiCapture = false;
void InputUpdateGUICapture(bool capt) {
    guiCapture = capt;
}

const UInt8 DIK_TO_ASCII[128] =
{
    DIK_A, DIK_S, DIK_D, DIK_F, DIK_H, DIK_G, DIK_Z, DIK_X,
    DIK_C, DIK_V, 0, DIK_B, DIK_Q
};

@interface IOSUtils()<EmulatorKeyboardKeyPressedDelegate>

@end

@implementation IOSUtils

+(id)shared {
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

-(NSDictionary*)dikToAsciiMap {
    return @{
        @(DIK_A) : [NSNumber numberWithUnsignedChar:'a'],
        @(DIK_S) : [NSNumber numberWithUnsignedChar:'s'],
        @(DIK_D) : [NSNumber numberWithUnsignedChar:'d'],
        @(DIK_F) : [NSNumber numberWithUnsignedChar:'f'],
        @(DIK_H) : [NSNumber numberWithUnsignedChar:'h'],
        @(DIK_G) : [NSNumber numberWithUnsignedChar:'g'],
        @(DIK_Z) : [NSNumber numberWithUnsignedChar:'z'],
        @(DIK_I) : [NSNumber numberWithUnsignedChar:'i'],
        @(DIK_Q) : [NSNumber numberWithUnsignedChar:'q'],
        @(DIK_K) : [NSNumber numberWithUnsignedChar:'k']
    };
}

- (void)keyDown:(id<KeyCoded> _Nonnull)key {
    event_t event = {};
    event.type = EV_KeyDown;
    event.data1 = (short) key.keyCode;
    NSLog(@"keyDown: code: %li", (long)key.keyCode);
    
    if (guiCapture) {
        NSLog(@"GUI Capture is On!");
        event.type = EV_GUI_Event;
        event.subtype = EV_GUI_KeyDown;
        BOOL isAsciiKey = NO;
        switch (key.keyCode) {
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
                short keyCode = (short) key.keyCode;
                NSNumber *asciiNumber = (NSNumber*) [[self dikToAsciiMap] objectForKey:@(keyCode)];
                if (asciiNumber != nil) {
                    unsigned char ascii = [asciiNumber unsignedCharValue];
                    NSLog(@"Found ascii %c (%hhd) for %li", ascii, ascii, (long)key.keyCode);
                    event.data1 = ascii;
                    isAsciiKey = YES;
                }
                break;
        }
        if (event.data1 < 128 && isAsciiKey) {
            event.data1 = toupper(event.data1);
//            event.data2 = 97; // testing..a - don't need to set this
            NSLog(@"keydown: posting gui key event for key %@, event.data1 = %i",key.keyLabel, event.data1);
            D_PostEvent(&event);
            // need to set this to output to console gui - looks like it needs to be the system character (utf-16?)
            unichar realchar = [key.keyLabel characterAtIndex:0];
            event.subtype = EV_GUI_Char;
            event.data1   = realchar;
            event.data2   = 0;
            D_PostEvent(&event);
            return;
        }
    }
    D_PostEvent(&event);
}

- (void)keyUp:(id<KeyCoded> _Nonnull)key {
    event_t event = {};
    event.type = EV_KeyUp;
    event.data1 = (short) key.keyCode;
    NSLog(@"keyUp: code: %li", (long)key.keyCode);
    if (guiCapture) {
        NSLog(@"GUI Capture is On!");
        event.type = EV_GUI_Event;
        event.subtype = EV_GUI_KeyUp;
        switch (key.keyCode) {
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
                short keyCode = (short) key.keyCode;
                NSNumber *asciiNumber = (NSNumber*) [[self dikToAsciiMap] objectForKey:@(keyCode)];
                if (asciiNumber != nil) {
                    unsigned char ascii = [asciiNumber unsignedCharValue];
                    NSLog(@"Found ascii %c (%hhd) for %li", ascii, ascii, (long)key.keyCode);
                    event.data1 = ascii;
                }
                break;
        }
        if (event.data1 < 128) {
            event.data1 = toupper(event.data1);
            event.data2 = 97; // testing..a
            NSLog(@"keyUp: posting gui key event for key %@, event.data1 = %i",key.keyLabel, event.data1);
            D_PostEvent(&event);
            return;
        }
    }
    D_PostEvent(&event);
}

@end

