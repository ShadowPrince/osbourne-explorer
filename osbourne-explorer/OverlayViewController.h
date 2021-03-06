//
//  OverlayViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

#import "RMUniversalAlert.h"

#import "MapOverlayStore.h"

@interface OverlayViewController : UIViewController <MapOverlayStoreDelegate, CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet GMSMapView *gMapView;
@property (nonatomic) MapOverlayStore *store;
@property (nonatomic) BOOL sharedResourcesUnloadedDueToMemory;

- (void) setContentInset:(UIEdgeInsets) inset;

@end
