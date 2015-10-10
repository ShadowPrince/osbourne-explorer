//
//  GroundOverlayInfoViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/10/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "GroundOverlayInfoViewController.h"

@interface GroundOverlayInfoViewController ()
@property OverlayViewController *overlayController;
@end@implementation GroundOverlayInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.overlayController = (OverlayViewController *) self.childViewControllers.lastObject;
    self.overlayController.store = [MapOverlayStore singleobjectInstanceWith:self.overlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    NSLog(@"%@ dealloc", self);
}

@end
