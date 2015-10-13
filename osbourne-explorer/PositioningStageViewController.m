//
//  PostioningStage.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "PositioningStageViewController.h"

@interface PositioningStageViewController ()
@property CGPoint point;
@end@implementation PositioningStageViewController

- (void) movePositionAbsolute:(CGPoint)p {
    self.point = p;

    if (self.delegate)
        [self.delegate didMovePositionTo:[self absolutePosition]];
}

- (void) movePositionRelative:(CGPoint)p {
    [self movePositionAbsolute:CGPointMake(p.x + self.point.x, p.y + self.point.y)];
}

- (CGPoint) absolutePosition {
    return self.point;
}

- (BOOL) isValid {
    return NO;
}

@end
