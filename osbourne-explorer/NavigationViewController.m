//
//  NavigationViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "NavigationViewController.h"

@interface NavigationViewController ()
@property IBOutlet MMDrawerController *drawer;
@end@implementation NavigationViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (void) viewDidLoad {
    self.drawer = self.childViewControllers.lastObject;

    UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationMap"];
    UIViewController *v2 = [self.storyboard instantiateViewControllerWithIdentifier:@"navigationMenu"];

    v.restorationClass = self.class;
    [self.drawer setCenterViewController:v];
    [self.drawer setRightDrawerViewController:v2];

    [self.drawer setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawer setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeTapCenterView];
}

- (void) viewDidAppear:(BOOL)animated {

    if (![SettingsController tutorialPassed]) {
        UIViewController *tutorialController = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorial"];
        UIButton *button = (UIButton *) [tutorialController.view viewWithTag:1];
        [button addTarget:self action:@selector(closeTutorial:) forControlEvents:UIControlEventTouchUpInside];

        UIWebView *webView = (UIWebView *) [tutorialController.view viewWithTag:2];
        webView.scrollView.contentInset = UIEdgeInsetsMake(44.f, 0, 0, 0);
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://shadowprince.github.io/osbourne-explorer/tutorial.html"]]];

        [self presentViewController:tutorialController animated:YES completion:nil];
    }
}

- (void) closeTutorial:(id) button {
    [SettingsController passTutorial];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction) unwindFromNewOverlay:(UIStoryboardSegue *) segue {

}

- (void) encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];

    [(NavigationMapViewController *) self.drawer.centerViewController encodeRestorableStateWithCoder:coder];
}

- (void) decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];

    [(NavigationMapViewController *) self.drawer.centerViewController decodeRestorableStateWithCoder:coder];
}

@end