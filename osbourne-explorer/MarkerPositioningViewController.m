//
//  MarkerPositioningViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MarkerPositioningViewController.h"

@interface MarkerPositioningViewController ()

@end@implementation MarkerPositioningViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.stages = @[[self.storyboard instantiateViewControllerWithIdentifier:@"mapPositioningStage"],
                    [self.storyboard instantiateViewControllerWithIdentifier:@"mapPositioningStage"], ];
}

- (void) didFinishedPositioning {

}

@end
