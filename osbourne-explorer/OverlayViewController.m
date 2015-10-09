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

@property MapOverlayStore *store;
@property NSMutableDictionary<MapOverlay *, GMSOverlay *> *gMapOverlays;

@end@implementation OverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.gMapOverlays = [NSMutableDictionary new];

    self.store = [MapOverlayStore sharedInstance];
    [self.store registerDelegate:self];

    GroundOverlay *overlay2 = [GroundOverlay new];
    overlay2.lat1 = 5;
    overlay2.lon1 = 5;
    overlay2.lat2 = 12;
    overlay2.lon2 = 20;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    overlay2.imageSrc = [documentsDirectory stringByAppendingString:@"/IMG_0014.JPG"];

    [self.store.allOverlays enumerateObjectsUsingBlock:^(MapOverlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self updateGOverlayForOverlay:obj withSettings:[self.store settingsForOverlay:obj]];
    }];

    [self.store insertMapOverlay:overlay2];

    [self addMarketAt:CLLocationCoordinate2DMake(5, 5)];
    [self addMarketAt:CLLocationCoordinate2DMake(12, 20)];


}

- (void) addMarketAt:(CLLocationCoordinate2D) coord {
    GMSMarker *marker = [GMSMarker markerWithPosition:coord];
    marker.map = self.gMapView;
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

        } else {
            gOverlay.icon = overlay.image;
        }
    }
}

#pragma mark - store delegate

- (void) didInsertedOverlay:(MapOverlay *)overlay withSettings:(MapOverlaySettings *)settings atPosition:(NSUInteger)position {
    GMSGroundOverlay *gOverlay = [GMSGroundOverlay new];
    self.gMapOverlays[overlay] = gOverlay;
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

@end
