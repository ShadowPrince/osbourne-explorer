//
//  DebugView.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/19/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "DebugView.h"

@interface DebugView ()
@property CGFloat w_scale, h_scale;
@property IBOutlet UIImageView *iv;
@end@implementation DebugView

- (void) viewDidAppear:(BOOL)animated {
    self.w_scale = self.img.size.width / self.iv.frame.size.width;
    self.h_scale = self.img.size.height / self.iv.frame.size.height;

    self.iv.image = self.img;

    NSMutableArray *points = self.points.mutableCopy;

    for (NSValue *v in points) {
        CGPoint p = v.CGPointValue;

        UIView *v = [UIView new];
        v.backgroundColor = [UIColor redColor];
        v.frame = CGRectMake(p.x / self.w_scale, p.y / self.h_scale, 10, 10);
        [self.view addSubview:v];
    }
}

@end
