//
//  MapOverlayStore.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/9/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapOverlay.h"

@interface MapOverlaySettings : NSObject
@property BOOL hidden;
@property BOOL semiTransparent;
@end

@protocol MapOverlayStoreDelegate <NSObject>
- (void) didInsertedOverlay:(MapOverlay *) overlay
               withSettings:(MapOverlaySettings *) settings
                 atPosition:(NSUInteger) position;
- (void) didRemovedOverlay:(MapOverlay *) overlay;
- (void) didUpdatedOverlay:(MapOverlay *) overlay;
- (void) didMoveOverlay:(MapOverlay *) overlay toPosition:(NSUInteger) pos;

@end

@interface MapOverlayStore : NSObject

- (NSArray<MapOverlay *> *) allOverlays;
- (MapOverlaySettings *) settingsForOverlay:(MapOverlay *) overlay;

- (void) insertMapOverlay:(MapOverlay *) overlay;
- (void) removeMapOverlay:(MapOverlay *) overlay;
- (void) moveOverlayFrom:(NSUInteger) from to:(NSUInteger) to;

- (void) registerDelegate:(id<MapOverlayStoreDelegate>) delegate;
- (void) removeDelegate:(id<MapOverlayStoreDelegate>) delegate;
- (void) didUpdatedOverlay:(MapOverlay *) overlay;

+ (instancetype) sharedInstance;
+ (instancetype) singleobjectInstanceWith:(MapOverlay *) overlay;
+ (NSOperationQueue *) sharedResourcesLoadingQueue;
@end
