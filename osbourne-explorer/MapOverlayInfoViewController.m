//
//  MapOverlayInfoViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/29/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MapOverlayInfoViewController.h"

@interface MapOverlayInfoViewController ()
@property (weak) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *transpButton;
@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property MapOverlayStore *store;
@property MapOverlaySettings *settings;
@property OverlayViewController *overlayController;

@property UIColor *defaultButtonColor;
@end@implementation MapOverlayInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.settings = [[MapOverlayStore sharedInstance] settingsForOverlay:self.overlay];

    self.store = [MapOverlayStore singleobjectInstanceWith:self.overlay];
    self.overlayController = (OverlayViewController *) self.childViewControllers.lastObject;
    self.overlayController.store = self.store;

    [self.overlayController.gMapView animateToLocation:self.overlay.locationCoordinate];
    self.nameLabel.text = self.overlay.title;
    [self.overlayController.gMapView animateToZoom:11.f];

    self.defaultButtonColor = [self.showButton titleColorForState:UIControlStateNormal];
    [self updateButtons];
}

- (void)didReceiveMemoryWarning {
    [self performSegueWithIdentifier:@"unwind" sender:nil];
}


- (void) updateButtons {
    if (self.settings.hidden) {
        [self.showButton setTitle:NSLocalizedString(@"Show", @"info view controller") forState:UIControlStateNormal];
        [self.showButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    } else {
        [self.showButton setTitle:NSLocalizedString(@"Hide", @"info view controller") forState:UIControlStateNormal];
        [self.showButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    }

    if (self.settings.semiTransparent) {
        [self.transpButton setTitle:NSLocalizedString(@"Make solid", @"info view controller") forState:UIControlStateNormal];
        [self.transpButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    } else {
        [self.transpButton setTitle:NSLocalizedString(@"Make semitr.", @"info view controller") forState:UIControlStateNormal];
        [self.transpButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    }
}

- (IBAction)transpButtonAction:(id)sender {
    self.settings.semiTransparent = !self.settings.semiTransparent;

    [[MapOverlayStore sharedInstance] didUpdatedOverlay:self.overlay];
    [self updateButtons];
}

- (IBAction)showButtonAction:(id)sender {
    self.settings.hidden = !self.settings.hidden;

    [[MapOverlayStore sharedInstance] didUpdatedOverlay:self.overlay];
    [self updateButtons];
}

- (IBAction)removeButtonAction:(id)sender {
    __weak MapOverlayInfoViewController *_self = self;
    [RMUniversalAlert showAlertInViewController:self
                                      withTitle:NSLocalizedString(@"Remove overlay confirmation", @"overlay info remove alert")
                                        message:NSLocalizedString(@"Remove overlay?", @"overlay info remove alert")
                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"overlay info remove alert")
                         destructiveButtonTitle:NSLocalizedString(@"Remove", @"overlay info remove alert")
                              otherButtonTitles:nil
                                       tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
                                           if (buttonIndex == alert.destructiveButtonIndex) {
                                               [[MapOverlayStore sharedInstance] removeMapOverlay:_self.overlay];
                                               [_self performSegueWithIdentifier:@"unwind" sender:nil];
                                           }
                                       }];
}

@end
