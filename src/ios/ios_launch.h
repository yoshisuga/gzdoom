//
//  ios_launch.h
//  GZDoom
//
//  Created by Yoshi Sugawara on 2/18/23.
//

#ifndef ios_launch_h
#define ios_launch_h

#import <UIKit/UIKit.h>

@interface StartViewController: UIViewController
@property(nonatomic, strong) UIButton *startButton;
@end

@interface GZDoomLauncherViewController: UIViewController
@end

@interface UIViewController(SDL_Launch)
-(void)startSDLMainWithArgs:(NSArray<NSString*>*)arguments;
@end

#endif /* ios_launch_h */
