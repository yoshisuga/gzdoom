//
//  SDL_iOS.h
//  SDL
//
//  Created by Yoshi Sugawara on 2/18/23.
//

#ifndef SDL_iOS_h
#define SDL_iOS_h

#if defined(__IPHONEOS__)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIViewController* SDL_iOS_GetLaunchViewController(void);

#endif

#endif /* SDL_iOS_h */
