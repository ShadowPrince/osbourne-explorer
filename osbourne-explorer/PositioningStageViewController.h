//
//  PostioningStage.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import GoogleMaps;

@protocol PositioningStageDelegate <NSObject>

- (void) didMovePositionTo:(CLLocationCoordinate2D) p;

@end

@interface PositioningStageViewController : UIViewController
@property (weak) NSObject<PositioningStageDelegate> *delegate;

- (BOOL) prefersControlBarHidden;
- (void) setContentInset:(UIEdgeInsets)inset;

- (NSArray<NSString *> *) validationErrors;

- (CLLocationCoordinate2D) absolutePosition;
- (void) movePositionRelative:(CLLocationCoordinate2D) p;
- (void) movePositionAbsolute:(CLLocationCoordinate2D) p;
- (NSArray<NSNumber *> *) relativeMoveSteps;

@end
