//
//  GroundOverlayInfoViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/10/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "GroundOverlayInfoViewController.h"

@interface GroundOverlayInfoViewController ()
@property (weak) IBOutlet UILabel *nameLabel;

@property OverlayViewController *overlayController;
@end@implementation GroundOverlayInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.overlayController = (OverlayViewController *) self.childViewControllers.lastObject;
    self.overlayController.store = [MapOverlayStore singleobjectInstanceWith:self.overlay];

    [self.overlayController.gMapView animateToLocation:self.overlay.locationCoordinate];
    self.nameLabel.text = self.overlay.title;
    [self.overlayController.gMapView animateToZoom:11.f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
