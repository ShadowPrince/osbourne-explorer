//
//  MarkerPositioningViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "DocumentsDirectory.h"
#import "BasicVector.h"
#import "UIImage-Extensions.h"

#import "PositioningViewController.h"
#import "MapPositioningStageViewController.h"
#import "ImagePositioningStageViewController.h"
#import "ImageResizingStageViewController.h"
#import "GroundOverlaySummaryPositioningStageViewController.h"

@interface GroundOverlayPositioningViewController : PositioningViewController
@property NSString *imageName;

@end
