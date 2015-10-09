//
//  MapOverlay.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/9/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MapOverlay.h"
#import "MapOverlayStore.h"

@implementation MapOverlay
@synthesize lat1, lon1, lat2, lon2, bearing;

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.lat1 = [aDecoder decodeDoubleForKey:@"lat1"];
    self.lon1 = [aDecoder decodeDoubleForKey:@"lon1"];
    self.lat2 = [aDecoder decodeDoubleForKey:@"lat2"];
    self.lon2 = [aDecoder decodeDoubleForKey:@"lon2"];
    self.bearing = [aDecoder decodeDoubleForKey:@"bearing"];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.lat1 forKey:@"lat1"];
    [aCoder encodeDouble:self.lon1 forKey:@"lon1"];
    [aCoder encodeDouble:self.lat2 forKey:@"lat2"];
    [aCoder encodeDouble:self.lon2 forKey:@"lon2"];
    [aCoder encodeDouble:self.bearing forKey:@"bearing"];
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

- (void) loadSharedResourcesCallback:(MapOverlayLoadCallback)cb {
    cb();
}

@end

@implementation GroundOverlay
@synthesize imageSrc, image, semitransparentImage;

- (instancetype) init {
    self = [super init];
    image = [UIImage imageNamed:@"placeholder_overlay"];
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    image = [UIImage imageNamed:@"placeholder_overlay"];
    self.imageSrc = [aDecoder decodeObjectForKey:@"imageSrc"];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.imageSrc forKey:@"imageSrc"];
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

- (void) loadSharedResourcesCallback:(MapOverlayLoadCallback)cb {
    if (self.imageSrc) {
        [MapOverlayStore.sharedResourcesLoadingQueue addOperationWithBlock:^{
            image = [UIImage imageWithContentsOfFile:self.imageSrc];

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                cb();
            }];
        }];
    }
}

@end
