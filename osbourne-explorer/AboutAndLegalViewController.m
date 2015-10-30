//
//  AboutAndLegalViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/29/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "AboutAndLegalViewController.h"

@interface AboutAndLegalViewController ()

@end@implementation AboutAndLegalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)homepageButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://shadowprince.github.io/osbourne-explorer"]];
}

- (IBAction)issuesTrackerButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/ShadowPrince/osbourne-explorer/issues"]];
}
- (IBAction)sourceButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/shadowprince/osbourne-explorer"]];
}

@end
