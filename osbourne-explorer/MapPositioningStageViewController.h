//
//  MapPositioningStageViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "PositioningStageViewController.h"
#import "OverlayViewController.h"
#import "MapOverlayStore.h"

@import GoogleMaps;

@interface MapPositioningStageViewController : PositioningStageViewController <GMSMapViewDelegate>

- (GMSCameraPosition *) camera;
- (void) setCamera:(GMSCameraPosition *) camera;

@end
