//
//  MapOverlay.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/9/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DocumentsDirectory.h"

typedef void (^MapOverlayLoadCallback)(void);

@interface MapOverlay : NSObject<NSCoding, NSCopying>
@property (assign) double lat1, lon1, lat2, lon2, bearing;
@property NSString *title;
@property BOOL sharedResourcesLoaded;

- (void) loadSharedResourcesCallback:(MapOverlayLoadCallback) cb;
- (void) unloadSharedResources;
- (void) cleanup;
@end

@interface GroundOverlay : MapOverlay
@property (readonly) UIImage *image, *semitransparentImage;
@property NSString *imageSrc;
@end

@interface MarkerOverlay : MapOverlay
@property NSString *iconName;
@property (readonly) UIImage *icon;
@end