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

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.hidden forKey:@"hidden"];
    [aCoder encodeBool:self.semiTransparent forKey:@"semiTransparent"];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.hidden = [aDecoder decodeBoolForKey:@"hidden"];
    self.semiTransparent = [aDecoder decodeBoolForKey:@"semiTransparent"];

    return self;
}

@end

@interface MapOverlayStore ()
@property NSMutableArray<MapOverlay *> *mapOverlays;
@property NSMutableArray<MapOverlaySettings *> *mapOverlaySettings;

@property NSString *databasePath;
@property NSMutableArray<id<MapOverlayStoreDelegate>> *delegates;
@property NSMutableArray<MapOverlayDelegateRespondStatus *> *delegateRespondStatuses;
@end@implementation MapOverlayStore

- (instancetype) init {
    self = [super init];
    self.mapOverlays = [NSMutableArray new];
    self.mapOverlaySettings = [NSMutableArray new];
    self.delegates = [NSMutableArray mutableArrayUsingWeakReferences];
    self.delegateRespondStatuses = [NSMutableArray new];
    return self;
}

+ (instancetype) sharedInstance {
    static MapOverlayStore *instance = nil;
    if (!instance) {
        instance = [self new];

        /*
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSLog(@"%@", documentsDirectory);

        GroundOverlay *overlay2 = [GroundOverlay new];
        overlay2.lat1 = 5;
        overlay2.lon1 = 5;
        overlay2.lat2 = 12;
        overlay2.lon2 = 12;
        overlay2.title = @"IMG_0014.JPG";
        overlay2.imageSrc = [documentsDirectory stringByAppendingString:@"/IMG_0013.PNG"];
        [instance insertMapOverlay:overlay2];

        MarkerOverlay *overlay1 = [MarkerOverlay new];
        overlay1.lat1 = 5;
        overlay1.lon1 = 5;
        overlay1.title = @"foobar";
        [instance insertMapOverlay:overlay1];

        MarkerOverlay *overlay3 = [MarkerOverlay new];
        overlay3.lat1 = 12;
        overlay3.lon1 = 12;
        overlay3.title = @"marker 3";
        [instance insertMapOverlay:overlay3];

         */
    }

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
    return self.mapOverlays;
}

- (MapOverlaySettings *) settingsForOverlay:(MapOverlay *)overlay {
    NSUInteger idx = [self.mapOverlays indexOfObject:overlay];
    return self.mapOverlaySettings[idx];
}

- (void) insertMapOverlay:(MapOverlay *)overlay {
    MapOverlaySettings *settings = [MapOverlaySettings new];
    [self.mapOverlays addObject:overlay];
    [self.mapOverlaySettings addObject:settings];
    [overlay loadSharedResourcesCallback:^{
        [self fireDidUpdatedOverlay:overlay];
    }];

    [self fireDidInsertedOverlay:overlay withSettings:settings atPosition:self.mapOverlays.count];
    [self save];
}

- (void) removeMapOverlay:(MapOverlay *)overlay {
    [self fireDidRemovedOverlay:overlay];

    [overlay cleanup];
    NSUInteger idx = [self.mapOverlays indexOfObject:overlay];
    [self.mapOverlays removeObject:overlay];
    [self.mapOverlaySettings removeObjectAtIndex:idx];
}

- (void) moveOverlayFrom:(NSUInteger) from to:(NSUInteger) to {
    MapOverlay *overlay = self.mapOverlays[from];
    [self.mapOverlays removeObjectAtIndex:from];
    [self.mapOverlays insertObject:overlay atIndex:to];
    [self save];
}

- (void) didUpdatedOverlay:(MapOverlay *)overlay {
    [self fireDidUpdatedOverlay:overlay];
    [self save];
}

- (void) requestSharedResourcesLoading {
    [self.mapOverlays enumerateObjectsUsingBlock:^(MapOverlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj loadSharedResourcesCallback:^{
            [self fireDidUpdatedOverlay:obj];
        }];
    }];
}

#pragma mark - persistence

- (void) save {
    NSString *path = self.databasePath;

    [NSKeyedArchiver archiveRootObject:self.mapOverlays toFile:[path stringByAppendingString:@".overlays"]];
    [NSKeyedArchiver archiveRootObject:self.mapOverlaySettings toFile:[path stringByAppendingString:@".overlay-settings"]];
}

- (void) loadFrom:(NSString *)path {
    self.databasePath = path;

    self.mapOverlays = [NSKeyedUnarchiver unarchiveObjectWithFile:[path stringByAppendingString:@".overlays"]];
    self.mapOverlaySettings = [NSKeyedUnarchiver unarchiveObjectWithFile:[path stringByAppendingString:@".overlay-settings"]];

    if (!self.mapOverlays || !self.mapOverlaySettings) {
        self.mapOverlays = [NSMutableArray new];
        self.mapOverlaySettings = [NSMutableArray new];
    }

    NSLog(@"%@ %@", self.mapOverlays.firstObject, self.mapOverlaySettings);

}

@end
