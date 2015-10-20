//
//  ImagePositioningView.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/14/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "ImagePositioningView.h"

#define CURSOR_STEP 1
#define TOUCH_TRESHHOLD 5

@interface ImagePositioningView ()
@property CGFloat w_scale, h_scale;
@property UIImageView *marker;

@property CGPoint relativePoint, absolutePoint;
@end@implementation ImagePositioningView

- (void) awakeFromNib {
    self.marker = [UIImageView new];
    self.marker.image = [UIImage imageNamed:@"marker_icon"];

    self.w_scale = 1.0f;
    self.h_scale = 1.0f;
    [self addSubview:self.marker];

    UILongPressGestureRecognizer *gestureRec = [UILongPressGestureRecognizer new];
    [self addGestureRecognizer:gestureRec];
    [gestureRec addTarget:self action:@selector(longPressAction:)];
}

- (IBAction)longPressAction:(UILongPressGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self];
    self.relativePoint = point;
    self.absolutePoint = CGPointMake((int) (point.x * self.w_scale), (int) (point.y * self.h_scale));

    [self updateMarker];
    [self.delegate didSelectedPoint:self.absolutePoint];
}

- (void) moveAbsolute:(CGPoint)p {
    self.absolutePoint = p;
    self.relativePoint = CGPointMake(p.x / self.w_scale, p.y / self.h_scale);

    [self updateMarker];
}

- (void) moveRelative:(CGPoint)p {
    [self moveAbsolute:CGPointMake(self.absolutePoint.x + p.x, self.absolutePoint.y + p.y)];
}

- (void) updateMarker {
    self.marker.frame = CGRectMake(self.relativePoint.x - self.marker.image.size.width / 2,
                                   self.relativePoint.y - self.marker.image.size.height,
                                   self.marker.image.size.width,
                                   self.marker.image.size.height);
}

@end
