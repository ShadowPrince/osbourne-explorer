//
//  MarkerInfoViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/12/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MarkerOverlayInfoViewController.h"

@interface MarkerOverlayInfoViewController ()
@property (weak) IBOutlet UILabel *nameLabel;

@property OverlayViewController *overlayController;
@end

@implementation MarkerOverlayInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.overlayController = (OverlayViewController *) self.childViewControllers.lastObject;
    self.overlayController.store = [MapOverlayStore singleobjectInstanceWith:self.marker];

    [self.overlayController.gMapView animateToLocation:self.marker.locationCoordinate];
    self.nameLabel.text = self.marker.title;
    [self.overlayController.gMapView animateToZoom:11.f];
}

@end
