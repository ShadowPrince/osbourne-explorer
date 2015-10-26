//
//  SettingsController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/26/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "SettingsController.h"

@interface SettingsController ()
@property (weak, nonatomic) IBOutlet UISwitch *restrictionsToggle;

@end@implementation SettingsController

+ (void) sync {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"initial_setup"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"initial_setup"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"overlay_size_restrictions"];
    }
}

+ (BOOL) restrictionsEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"overlay_size_restrictions"];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:@"overlay_size_restrictions"];
    [self.restrictionsToggle setOn:val];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    BOOL b = self.restrictionsToggle.on;
    [[NSUserDefaults standardUserDefaults] setBool:b forKey:@"overlay_size_restrictions"];
}



@end
