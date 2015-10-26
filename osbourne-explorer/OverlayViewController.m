//
//  OverlayViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "OverlayViewController.h"

@interface OverlayViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomGuide;

@property NSMutableDictionary<MapOverlay *, GMSOverlay *> *gMapOverlays;

@property BOOL overlaysHidden, overlaysSemitransparent;

@end@implementation OverlayViewController

- (void) didReceiveMemoryWarning {
    self.overlaysHidden = YES;
    [self.store.allOverlays enumerateObjectsUsingBlock:^(MapOverlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.store settingsForOverlay:obj].hidden = YES;
        [self.store didUpdatedOverlay:obj];
    }];

    self.gMapView.myLocationEnabled = YES;
    [self.store requestSharedResourcesUnloading];
    [RMUniversalAlert showAlertInViewController:self
                                      withTitle:@"Memory issue"
                                        message:@"Overlays was hided due to memory issue. Try following steps: \n - hide/show application\n - restart application"
                              cancelButtonTitle:@"Ok"
                         destructiveButtonTitle:nil
                              otherButtonTitles:nil
                                       tapBlock:nil];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.gMapOverlays = [NSMutableDictionary new];
    self.gMapView.myLocationEnabled = YES;
}

- (void) setContentInset:(UIEdgeInsets)inset {
    self.bottomGuide.constant = inset.bottom;
    self.gMapView.padding = inset;
    [self.view setNeedsLayout];
}

- (void) setStore:(MapOverlayStore *) store {
    _store = store;

    [self.gMapView clear];
    [self.gMapOverlays enumerateKeysAndObjectsUsingBlock:^(MapOverlay * _Nonnull key, GMSOverlay * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.map = nil;
    }];
    [self.gMapOverlays removeAllObjects];

    [self.store registerDelegate:self];
    [self.store requestSharedResourcesLoading];
}

- (void) requestSharedResourcesLoading {
    [self.store.allOverlays enumerateObjectsUsingBlock:^(MapOverlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertGOverlay:obj];
        [self updateGOverlayForOverlay:obj withSettings:[self.store settingsForOverlay:obj]];
    }];
}

- (void) requestSharedResourcesUnloading {
    [self.gMapView clear];
    [self.gMapOverlays enumerateKeysAndObjectsUsingBlock:^(MapOverlay * _Nonnull key, GMSOverlay * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[GroundOverlay class]]) {
            GMSGroundOverlay *gOverlay = (GMSGroundOverlay *) obj;
            gOverlay.icon = nil;
        }
    }];
    [self.gMapOverlays removeAllObjects];
}

- (void) addMarketAt:(CLLocationCoordinate2D) coord {
    GMSMarker *marker = [GMSMarker markerWithPosition:coord];
    marker.map = self.gMapView;
}

- (void) insertGOverlay:(MapOverlay *) overlay {
    GMSOverlay *gOverlay;

    if ([overlay isKindOfClass:[GroundOverlay class]]) {
        gOverlay = [GMSGroundOverlay new];
    } else if ([overlay isKindOfClass:[MarkerOverlay class]]) {
        gOverlay = [GMSMarker new];
    }

    self.gMapOverlays[overlay] = gOverlay;
}

- (void) updateGOverlayForOverlay:(MapOverlay *) uncasted_overlay withSettings:(MapOverlaySettings *) settings {
    //@TODO: called too often 
    if ([uncasted_overlay isKindOfClass:[GroundOverlay class]]) {
        GroundOverlay *overlay = (GroundOverlay *) uncasted_overlay;
        GMSGroundOverlay *gOverlay = (GMSGroundOverlay *) self.gMapOverlays[overlay];

        CLLocationCoordinate2D c1 = CLLocationCoordinate2DMake(overlay.lat1, overlay.lon1);
        CLLocationCoordinate2D c2 = CLLocationCoordinate2DMake(overlay.lat2, overlay.lon2);
        gOverlay.bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:c1 coordinate:c2];
        gOverlay.bearing = overlay.bearing;

        // settings
        if (settings.hidden) {
            gOverlay.map = nil;
            gOverlay.icon = nil;
        } else {
            gOverlay.map = self.gMapView;

            if (settings.semiTransparent) {
                gOverlay.icon = overlay.semitransparentImage;
            } else {
                gOverlay.icon = overlay.image;
            }
        }
    } else if ([uncasted_overlay isKindOfClass:[MarkerOverlay class]]) {
        MarkerOverlay *overlay = (MarkerOverlay *) uncasted_overlay;
        GMSMarker *gMarker = (GMSMarker *) self.gMapOverlays[overlay];

        gMarker.position = CLLocationCoordinate2DMake(overlay.lat1, overlay.lon1);
        gMarker.title = overlay.title;
        if (overlay.iconName)
            gMarker.icon = overlay.icon;

        if (settings.hidden) {
            gMarker.map = nil;
        } else {
            gMarker.map = self.gMapView;
        }
    }
}

#pragma mark - store delegate

- (void) didInsertedOverlay:(MapOverlay *)overlay withSettings:(MapOverlaySettings *)settings atPosition:(NSUInteger)position {
    [self insertGOverlay:overlay];
    // @TODO: positioning

    [self updateGOverlayForOverlay:overlay
                      withSettings:settings];
}

- (void) didRemovedOverlay:(MapOverlay *)overlay {
    GMSOverlay *gOverlay = self.gMapOverlays[overlay];
    gOverlay.map = nil;

    [self.gMapOverlays removeObjectForKey:overlay];
}

- (void) didUpdatedOverlay:(MapOverlay *)overlay {
    if (!self.gMapOverlays[overlay])
        [self insertGOverlay:overlay];
    
    [self updateGOverlayForOverlay:overlay
                      withSettings:[self.store settingsForOverlay:overlay]];
}

#pragma mark - controls

- (IBAction)overlaysToggleAction:(id)sender {
    self.overlaysHidden = !self.overlaysHidden;
    [self.store.allOverlays enumerateObjectsUsingBlock:^(MapOverlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.store settingsForOverlay:obj].hidden = self.overlaysHidden;
        [self.store didUpdatedOverlay:obj];
    }];
}

- (IBAction)semitransparentToggleAction:(id)sender {
    self.overlaysSemitransparent = !self.overlaysSemitransparent;

    [self.store.allOverlays enumerateObjectsUsingBlock:^(MapOverlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.store settingsForOverlay:obj].semiTransparent = self.overlaysSemitransparent;
        [self.store didUpdatedOverlay:obj];
    }];
}

- (IBAction)mapTypeToggleAction:(id)sender {
    if (self.gMapView.mapType == kGMSTypeNormal) {
        self.gMapView.mapType = kGMSTypeSatellite;
    } else {
        self.gMapView.mapType = kGMSTypeNormal;
    }
}

- (IBAction)gpsAction:(id)sender {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        [RMUniversalAlert showAlertInViewController:self
                                          withTitle:NSLocalizedString(@"Error", @"gpsAction alert")
                                            message:NSLocalizedString(@"GPS authorization denied. Check location settings for the app, allow location access", @"gpsAction alert")
                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"gpsAction alert")
                             destructiveButtonTitle:nil
                                  otherButtonTitles:nil
                                           tapBlock:nil];
    } else if (status == kCLAuthorizationStatusRestricted) {
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];
    } else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.gMapView animateToLocation:self.gMapView.myLocation.coordinate];
        if (self.gMapView.camera.zoom < 15.f)
            [self.gMapView animateToZoom:15.f];
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"@%", locations);
}

- (void) dealloc {
    NSLog(@"%@ dealloc", self);
}

@end
