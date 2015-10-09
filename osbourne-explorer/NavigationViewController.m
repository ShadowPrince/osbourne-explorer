//
//  NavigationViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "NavigationViewController.h"

@interface NavigationViewController ()
@property IBOutlet MMDrawerController *drawer;
@end@implementation NavigationViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (void) viewDidLoad {
    self.drawer = self.childViewControllers.lastObject;

    UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationMap"];
    UIViewController *v2 = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationMenu"];

    [self.drawer setCenterViewController:v];
    [self.drawer setRightDrawerViewController:v2];

    [self.drawer setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawer setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeTapCenterView];
}

@end
