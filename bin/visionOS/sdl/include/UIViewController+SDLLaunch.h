//
//  UIViewController+SDLLaunch.h
//  SDL
//
//  Created by Yoshi Sugawara on 2/18/23.
//

#ifndef UIViewController_SDLLaunch_h
#define UIViewController_SDLLaunch_h

#if defined(__IPHONEOS__)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIViewController(SDL_Launch)
-(void)startSDLMainWithArgs:(NSArray<NSString*>*)arguments;
@end

#endif


#endif /* UIViewController_SDLLaunch_h */
