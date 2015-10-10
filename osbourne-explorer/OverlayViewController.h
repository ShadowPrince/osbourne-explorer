//
//  OverlayViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

#import "MapOverlayStore.h"

@interface OverlayViewController : UIViewController <MapOverlayStoreDelegate>
@property (nonatomic) MapOverlayStore *store;

@end
