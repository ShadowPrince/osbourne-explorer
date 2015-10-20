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
@synthesize lat1, lon1, lat2, lon2, bearing, title;
@synthesize sharedResourcesLoaded;

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.lat1 = [aDecoder decodeDoubleForKey:@"lat1"];
    self.lon1 = [aDecoder decodeDoubleForKey:@"lon1"];
    self.lat2 = [aDecoder decodeDoubleForKey:@"lat2"];
    self.lon2 = [aDecoder decodeDoubleForKey:@"lon2"];
    self.bearing = [aDecoder decodeDoubleForKey:@"bearing"];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.lat1 forKey:@"lat1"];
    [aCoder encodeDouble:self.lon1 forKey:@"lon1"];
    [aCoder encodeDouble:self.lat2 forKey:@"lat2"];
    [aCoder encodeDouble:self.lon2 forKey:@"lon2"];
    [aCoder encodeDouble:self.bearing forKey:@"bearing"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

- (void) loadSharedResourcesCallback:(MapOverlayLoadCallback)cb {
    if (!self.sharedResourcesLoaded) {
        self.sharedResourcesLoaded = YES;
        cb();
    }
}

- (void) cleanup {}

@end

@implementation MarkerOverlay
@synthesize iconName;
@synthesize icon;
- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.iconName = [aDecoder decodeObjectForKey:@"iconName"];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.title forKey:@"iconName"];
}

- (void) loadSharedResourcesCallback:(MapOverlayLoadCallback)cb {
    [super loadSharedResourcesCallback:^{
        if (self.iconName) {
            [MapOverlayStore.sharedResourcesLoadingQueue addOperationWithBlock:^{
                icon = [UIImage imageNamed:self.iconName];

                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    cb();
                }];
            }];
        }
    }];
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
    [super loadSharedResourcesCallback:^{
        if (self.imageSrc) {
            [MapOverlayStore.sharedResourcesLoadingQueue addOperationWithBlock:^{
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                image = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingString:self.imageSrc]];
                semitransparentImage = [self generateSemitransparentImage:self.image alpha:0.3f];

                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    cb();
                }];
            }];
        }
    }];
}

- (void) cleanup {
    NSString *filename = [self.imageSrc componentsSeparatedByString:@"/"].lastObject;
    if ([filename hasPrefix:@"._"]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.imageSrc error:nil];
    }
}

- (UIImage *) generateSemitransparentImage:(UIImage *) x alpha:(CGFloat) alpha {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    [x drawInRect:imageRect blendMode:kCGBlendModeCopy alpha:alpha];

    UIImage* outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

@end
