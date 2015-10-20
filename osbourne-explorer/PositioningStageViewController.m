//
//  PostioningStage.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "PositioningStageViewController.h"

@interface PositioningStageViewController ()
@property CLLocationCoordinate2D point;
@property BOOL pointSet;
@end@implementation PositioningStageViewController

- (void) movePositionAbsolute:(CLLocationCoordinate2D)p {
    self.point = p;
    self.pointSet = YES;

    if (self.delegate)
        [self.delegate didMovePositionTo:[self absolutePosition]];
}

- (void) movePositionRelative:(CLLocationCoordinate2D)p {
    [self movePositionAbsolute:CLLocationCoordinate2DMake(p.latitude * self.relativeMoveSteps[0].doubleValue + self.point.latitude,
                                                          p.longitude * self.relativeMoveSteps[1].doubleValue + self.point.longitude)];
}

- (NSArray<NSNumber *> *) relativeMoveSteps {
    return @[@1.0f, @1.0f];
}

- (CLLocationCoordinate2D) absolutePosition {
    return self.point;
}

- (BOOL) isValid {
    return self.pointSet;
}

@end
