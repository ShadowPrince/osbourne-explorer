//
//  SettingsController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/26/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMUniversalAlert.h"
#import "DocumentsDirectory.h"
#import "MapOverlayStore.h"

#import "ForcedNavbarViewController.h"

@interface SettingsController : ForcedNavbarViewController

+ (void) sync;
+ (BOOL) restrictionsEnabled;
+ (BOOL) tutorialPassed;
+ (void) passTutorial;

@end
