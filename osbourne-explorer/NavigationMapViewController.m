//
//  NavigationViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "NavigationMapViewController.h"

/* Handles OverlayViewController + control buttons
 */

@interface NavigationMapViewController ()
@property OverlayViewController *overlayController;

@end@implementation NavigationMapViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    MapOverlayStore *store = [MapOverlayStore sharedInstance];
    [store loadFrom:[DocumentsDirectory pathFor:@"/database"]];

    self.overlayController = (OverlayViewController *) self.childViewControllers.lastObject;
    self.overlayController.store = store;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.overlayController.sharedResourcesUnloadedDueToMemory) {
        [RMUniversalAlert showAlertInViewController:self
                                          withTitle:NSLocalizedString(@"Memory issue", @"memory issue alert")
                                            message:NSLocalizedString(@"Overlays was hided due to memory issue. Try following steps: \n - hide/show application\n - restart application", @"memory issue alert")
                                  cancelButtonTitle:@"Ok"
                             destructiveButtonTitle:nil
                                  otherButtonTitles:nil
                                           tapBlock:nil];
    }
}

- (void) decodeRestorableStateWithCoder:(NSCoder *)coder {
    GMSCameraPosition *gCamera = [GMSCameraPosition cameraWithLatitude:[coder decodeDoubleForKey:@"camera_lat"]
                                                             longitude:[coder decodeDoubleForKey:@"camera_lon"]
                                                                  zoom:[coder decodeFloatForKey:@"camera_zoom"]
                                                               bearing:[coder decodeDoubleForKey:@"camera_bearing"]
                                                          viewingAngle:[coder decodeDoubleForKey:@"camera_angle"]];


    self.overlayController.gMapView.camera = gCamera;
}

- (void) encodeRestorableStateWithCoder:(NSCoder *)coder {
    GMSCameraPosition *gCamera = self.overlayController.gMapView.camera;

    [coder encodeDouble:gCamera.target.latitude forKey:@"camera_lat"];
    [coder encodeDouble:gCamera.target.longitude forKey:@"camera_lon"];
    [coder encodeDouble:gCamera.bearing forKey:@"camera_bearing"];
    [coder encodeFloat:gCamera.zoom forKey:@"camera_zoom"];
    [coder encodeDouble:gCamera.viewingAngle forKey:@"camera_angle"];
}

@end
