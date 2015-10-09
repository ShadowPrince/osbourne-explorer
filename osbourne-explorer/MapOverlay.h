//
//  MapOverlay.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/9/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^MapOverlayLoadCallback)(void);

@interface MapOverlay : NSObject<NSCoding, NSCopying>
@property (assign) double lat1, lon1, lat2, lon2, bearing;

- (void) loadSharedResourcesCallback:(MapOverlayLoadCallback) cb;
@end

@interface GroundOverlay : MapOverlay
@property (readonly) UIImage *image, *semitransparentImage;
@property NSString *imageSrc;
@end

@interface MarkerOverlay : MapOverlay
@property NSString *title;
@end