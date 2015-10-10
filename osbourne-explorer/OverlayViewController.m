//
//  OverlayViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "OverlayViewController.h"

@interface OverlayViewController ()
@property (weak, nonatomic) IBOutlet GMSMapView *gMapView;

@property NSMutableDictionary<MapOverlay *, GMSOverlay *> *gMapOverlays;

@property BOOL overlaysHidden, overlaysSemitransparent;

@end@implementation OverlayViewController

- (void) setStore:(MapOverlayStore *) store {
    _store = store;

    [self.gMapOverlays enumerateKeysAndObjectsUsingBlock:^(MapOverlay * _Nonnull key, GMSOverlay * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.map = nil;
    }];
    self.gMapOverlays = [NSMutableDictionary new];

    [self.store registerDelegate:self];
    [self.store requestSharedResourcesLoading];
    [self.store.allOverlays enumerateObjectsUsingBlock:^(MapOverlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertGOverlay:obj];
        [self updateGOverlayForOverlay:obj withSettings:[self.store settingsForOverlay:obj]];
    }];
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
        } else {
            gOverlay.map = self.gMapView;
        }

        if (settings.semiTransparent) {
            gOverlay.icon = overlay.semitransparentImage;
        } else {
            gOverlay.icon = overlay.image;
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

- (void) dealloc {
    NSLog(@"%@ dealloc", self);
}

@end
