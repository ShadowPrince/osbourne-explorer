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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.imageView.image = self.image;
    self.scrollView.zoomScale = self.scrollView.frame.size.width / self.image.size.width;
}

- (void) setImage:(UIImage *)image {
    _image = image;

    self.imageView.image = self.image;
    self.scrollView.zoomScale = self.scrollView.frame.size.width / self.image.size.width;
    self.scrollView.contentOffset = CGPointZero;
}

- (void) setContentInset:(UIEdgeInsets)inset {
    self.scrollView.contentInset = inset;
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

@end
