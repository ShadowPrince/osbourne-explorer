//
//  MarkerPositioningViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/20/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MarkerPositioningViewController.h"

@interface MarkerPositioningViewController ()

@end

@implementation MarkerPositioningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stages = @[[self.storyboard instantiateViewControllerWithIdentifier:@"mapPositioningStage"],
                    [self.storyboard instantiateViewControllerWithIdentifier:@"markerSummaryPositioningStage"], ].mutableCopy;
}

- (void) didFinishedPositioning {
    MarkerOverlay *overlay = [MarkerOverlay new];
    CLLocationCoordinate2D p = self.stages.firstObject.absolutePosition;
    MarkerSummaryPositioningStageViewController *nfController = (MarkerSummaryPositioningStageViewController *) self.stages.lastObject;

    overlay.lat1 = p.latitude;
    overlay.lon1 = p.longitude;
    overlay.title = nfController.nameValue;
    overlay.iconName = [(MarkerSummaryPositioningStageViewController *) self.stages.lastObject markerIconNameValue];

    [[MapOverlayStore sharedInstance] insertMapOverlay:overlay];
    [self performSegueWithIdentifier:@"finishUnwind" sender:nil];
}

- (void) didCanceledPositioning {
}

@end
