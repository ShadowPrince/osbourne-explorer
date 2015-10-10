//
//  NavigationViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "NavigationMapViewController.h"

/* Handles OverlayViewController + control buttons
 */

@interface NavigationMapViewController ()
@property OverlayViewController *overlayController;

@end@implementation NavigationMapViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    self.overlayController = (OverlayViewController *) self.childViewControllers.lastObject;
    self.overlayController.store = [MapOverlayStore sharedInstance];
}

@end
