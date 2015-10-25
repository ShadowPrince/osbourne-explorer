//
//  GroundOverlaySummaryPositioningStageViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/23/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositioningStageViewController.h"

@interface GroundOverlaySummaryPositioningStageViewController : PositioningStageViewController<UITextFieldDelegate>
@property NSString *defaultName;

- (NSString *) nameValue;
@end
