//
//  MapOverlayStore.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/9/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MapOverlayStore.h"

@interface MapOverlayDelegateRespondStatus : NSObject
@property BOOL didInsertedOverlay, didRemovedOverlay, didUpdatedOverlay, didMoveOverlay;
@end@implementation MapOverlayDelegateRespondStatus@end
@implementation MapOverlaySettings
@synthesize hidden, semiTransparent;
@end

@interface MapOverlayStore ()
@property NSMutableArray<MapOverlay *> *mapOverlays;
@property NSMutableDictionary<MapOverlay *, MapOverlaySettings *> *mapOverlaySettings;

@property NSMutableArray<id<MapOverlayStoreDelegate>> *delegates;
@property NSMutableArray<MapOverlayDelegateRespondStatus *> *delegateRespondStatuses;
@end@implementation MapOverlayStore

- (instancetype) init {
    self = [super init];
    self.mapOverlays = [NSMutableArray new];
    self.mapOverlaySettings = [NSMutableDictionary new];
    self.delegates = [NSMutableArray new];
    self.delegateRespondStatuses = [NSMutableArray new];
    return self;
}

+ (instancetype) sharedInstance {
    static MapOverlayStore *instance = nil;
    if (!instance)
        instance = [self new];

    return instance;
}

+ (instancetype) singleobjectInstanceWith:(MapOverlay *)overlay {
    MapOverlayStore *instance = [self new];
    [instance insertMapOverlay:overlay];

    return instance;
}

+ (NSOperationQueue *) sharedResourcesLoadingQueue {
    static NSOperationQueue *queue = nil;
    if (!queue)
        queue = [NSOperationQueue new];
    return queue;
}

#pragma mark - delegate

- (void) registerDelegate:(id<MapOverlayStoreDelegate>)delegate {
    MapOverlayDelegateRespondStatus *respondStatus = [MapOverlayDelegateRespondStatus new];
    respondStatus.didInsertedOverlay = [delegate respondsToSelector:@selector(didInsertedOverlay:withSettings:atPosition:)];
    respondStatus.didRemovedOverlay = [delegate respondsToSelector:@selector(didRemovedOverlay:)];
    respondStatus.didUpdatedOverlay = [delegate respondsToSelector:@selector(didUpdatedOverlay:)];
    respondStatus.didMoveOverlay = [delegate respondsToSelector:@selector(didMoveOverlay:toPosition:)];

    [self.delegates addObject:delegate];
    [self.delegateRespondStatuses addObject:respondStatus];
}

- (void) removeDelegate:(id<MapOverlayStoreDelegate>)delegate {
    NSUInteger idx = [self.delegates indexOfObject:delegate];

    [self.delegates removeObject:delegate];
    [self.delegateRespondStatuses removeObjectAtIndex:idx];
}

#pragma mark firing helper methods

- (void) fireDidInsertedOverlay:(MapOverlay *) overlay withSettings:(MapOverlaySettings *) settings atPosition:(NSUInteger) position {
    [self.delegateRespondStatuses enumerateObjectsUsingBlock:^(MapOverlayDelegateRespondStatus * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<MapOverlayStoreDelegate> key = self.delegates[idx];
        if (obj.didInsertedOverlay)
            [key didInsertedOverlay:overlay withSettings:settings atPosition:position];
    }];
}

- (void) fireDidUpdatedOverlay:(MapOverlay *) overlay {
    [self.delegateRespondStatuses enumerateObjectsUsingBlock:^(MapOverlayDelegateRespondStatus * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<MapOverlayStoreDelegate> key = self.delegates[idx];
        if (obj.didUpdatedOverlay)
            [key didUpdatedOverlay:overlay];
    }];
}

- (void) fireDidRemovedOverlay:(MapOverlay *) overlay {
    [self.delegateRespondStatuses enumerateObjectsUsingBlock:^(MapOverlayDelegateRespondStatus * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<MapOverlayStoreDelegate> key = self.delegates[idx];
        if (obj.didRemovedOverlay)
            [key didRemovedOverlay:overlay];
    }];
}

- (void) fireDidMovedOverlay:(MapOverlay *) overlay toPosition:(NSUInteger) position {
    [self.delegateRespondStatuses enumerateObjectsUsingBlock:^(MapOverlayDelegateRespondStatus * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<MapOverlayStoreDelegate> key = self.delegates[idx];
        if (obj.didMoveOverlay)
            [key didMoveOverlay:overlay toPosition:position];
    }];
}

#pragma mark - overlays

- (NSArray<MapOverlay *> *) allOverlays {
    [self.mapOverlays enumerateObjectsUsingBlock:^(MapOverlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj loadSharedResourcesCallback:^{
            [self fireDidUpdatedOverlay:obj];
        }];
    }];

    return self.mapOverlays;
}

- (MapOverlaySettings *) settingsForOverlay:(MapOverlay *)overlay {
    return self.mapOverlaySettings[overlay];
}

- (void) insertMapOverlay:(MapOverlay *)overlay {
    MapOverlaySettings *settings = [MapOverlaySettings new];
    [self.mapOverlays addObject:overlay];
    self.mapOverlaySettings[overlay] = settings;
    [overlay loadSharedResourcesCallback:^{
        [self fireDidUpdatedOverlay:overlay];
    }];

    [self fireDidInsertedOverlay:overlay withSettings:settings atPosition:self.mapOverlays.count];
}

- (void) removeMapOverlay:(MapOverlay *)overlay {
    [self fireDidRemovedOverlay:overlay];

    [self.mapOverlays removeObject:overlay];
    [self.mapOverlaySettings removeObjectForKey:overlay];
}

- (void) moveOverlayFrom:(NSUInteger) from to:(NSUInteger) to {
    MapOverlay *overlay = self.mapOverlays[from];
    [self.mapOverlays removeObjectAtIndex:from];
    [self.mapOverlays insertObject:overlay atIndex:to];
}

- (void) didUpdatedOverlay:(MapOverlay *)overlay {
    [self fireDidUpdatedOverlay:overlay];
}

@end
