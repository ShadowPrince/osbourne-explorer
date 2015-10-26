//
//  MapPositioningStageViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MapPositioningStageViewController.h"
#define CURSOR_STEP 0.0002

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

#pragma mark - api

- (void) movePositionAbsolute:(CLLocationCoordinate2D)p {
    [super movePositionAbsolute:p];
    [self createOrUpdateMarkerFor:p];
}

- (NSArray<NSNumber *> *) relativeMoveSteps {
    return @[@-CURSOR_STEP, @-CURSOR_STEP];
}

- (void) mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self movePositionAbsolute:coordinate];
}

- (void) setContentInset:(UIEdgeInsets)inset {
    [(OverlayViewController *) self.childViewControllers.lastObject setContentInset:inset];
}

- (NSString *) description {
    return NSLocalizedString(@"Select corresponding point", @"SVC title");
}

#pragma mark - public

- (GMSCameraPosition *) camera {
    return self.mapView.camera;
}

- (void) setCamera:(GMSCameraPosition *)camera {
    self.mapView.camera = camera;
}

#pragma mark - helper

- (void) createOrUpdateMarkerFor:(CLLocationCoordinate2D) pos {
    if (!self.pointMarker) {
        self.pointMarker = [GMSMarker new];
        self.pointMarker.map = self.mapView;
    }

    self.pointMarker.position = pos;
}


@end
