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

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", documentsDirectory);

    MapOverlayStore *store = [MapOverlayStore sharedInstance];
    [store loadFrom:[documentsDirectory stringByAppendingString:@"/database"]];

    self.overlayController = (OverlayViewController *) self.childViewControllers.lastObject;
    self.overlayController.store = store;
}

@end
