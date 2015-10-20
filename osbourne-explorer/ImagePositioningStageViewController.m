//
//  ImagePositioningStageViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/14/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "ImagePositioningStageViewController.h"

@interface ImagePositioningStageViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet ImagePositioningView *imageView;

@end@implementation ImagePositioningStageViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    self.image = self.image;
}

- (void) didSelectedPoint:(CGPoint)p {
    [super movePositionAbsolute:CLLocationCoordinate2DMake(p.y, p.x)];
    [self.delegate didMovePositionTo:self.absolutePosition];
}

- (void) movePositionAbsolute:(CLLocationCoordinate2D)p {
    [super movePositionAbsolute:p];
    [self.imageView moveAbsolute:CGPointMake(p.longitude, p.latitude)];
}

- (NSArray<NSNumber *> *) relativeMoveSteps {
    return @[@1, @(-1)];
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (NSString *) description {
    return @"Select point on map";
}

- (void) setImage:(UIImage *)img {
    _image = img;

    self.imageView.image = img;
    self.scrollView.zoomScale = 0.1f;
    // @TODO: zoom scale
}

@end
