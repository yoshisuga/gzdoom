//
//  ios_launch.m
//  zdoom
//
//  Created by Yoshi Sugawara on 2/18/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ios_launch.h"

#import "GenZD-Swift.h"

#include "SDL_iOS.h"

@implementation StartViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.startButton setTitle:@"Start!" forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(doStart:) forControlEvents:UIControlEventTouchUpInside];
    [self.startButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.startButton];
    [[self.startButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive:YES];
    [[self.startButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor] setActive:YES];
}

-(void)doStart:(id)sender {
  [self startSDLMainWithArgs:@[@"hello"]];
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end

UIViewController* SDL_iOS_GetLaunchViewController() {
  UIViewController *launchController = [LauncherViewControllerFactory create];
  return launchController;
}
