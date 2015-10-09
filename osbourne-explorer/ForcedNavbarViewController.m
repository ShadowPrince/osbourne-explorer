//
//  ForcedNavbarViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "ForcedNavbarViewController.h"

@interface ForcedNavbarViewController ()

@end@implementation ForcedNavbarViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


@end
