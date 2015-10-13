//
//  PostioningStage.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PositioningStageDelegate <NSObject>

- (void) didMovePositionTo:(CGPoint) p;

@end

@interface PositioningStageViewController : UIViewController
@property (weak) NSObject<PositioningStageDelegate> *delegate;

- (BOOL) isValid;
- (CGPoint) absolutePosition;
- (void) movePositionRelative:(CGPoint) p;
- (void) movePositionAbsolute:(CGPoint) p;

@end
