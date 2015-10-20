//
//  PositioningViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapOverlayStore.h"
#import "PositioningStageViewController.h"

#import "RMUniversalAlert.h"

@interface PositioningViewController : UIViewController <PositioningStageDelegate, UITextFieldDelegate>
@property NSArray<PositioningStageViewController *> *stages;

- (void) didFinishedPositioning;
- (void) didCanceledPositioning;
- (void) willMoveFrom:(PositioningStageViewController *) current to:(PositioningStageViewController *) next;
- (void) didMovedFrom:(PositioningStageViewController *) prev to:(PositioningStageViewController *) current;

- (NSArray<NSString *> *) validationErrors;

@end
