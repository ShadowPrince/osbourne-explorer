//
//  MarkerInfoViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/12/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MarkerOverlayInfoViewController.h"

@interface MarkerOverlayInfoViewController ()
@property OverlayViewController *overlayController;
@end

@implementation MarkerOverlayInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.overlayController = (OverlayViewController *) self.childViewControllers.lastObject;
    self.overlayController.store = [MapOverlayStore singleobjectInstanceWith:self.marker];
}

@end
