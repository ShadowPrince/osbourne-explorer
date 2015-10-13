//
//  MapPositioningStageViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MapPositioningStageViewController.h"

@interface MapPositioningStageViewController ()
@property IBOutlet GMSMapView *mapView;
@property GMSMarker *pointMarker;
@end@implementation MapPositioningStageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    OverlayViewController *overlayViewController = (OverlayViewController *) self.childViewControllers.lastObject;
    overlayViewController.store = [MapOverlayStore sharedInstance];
    self.mapView = overlayViewController.gMapView;
    self.mapView.delegate = self;
}

- (void) createOrUpdateMarkerFor:(CGPoint) pos {
    if (!self.pointMarker) {
        self.pointMarker = [GMSMarker new];
        self.pointMarker.map = self.mapView;
    }

    self.pointMarker.position = CLLocationCoordinate2DMake(pos.y, pos.x);
}

- (void) movePositionAbsolute:(CGPoint)p {
    [super movePositionAbsolute:p];
    [self createOrUpdateMarkerFor:p];
}

- (void) mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self movePositionAbsolute:CGPointMake(coordinate.longitude, coordinate.latitude)];
}

- (BOOL) isValid {
    return self.pointMarker != nil;
}

- (NSString *) description {
    return NSLocalizedString(@"Select corresponding point", @"SVC title");
}

@end
