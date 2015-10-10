//
//  GroundOverlayInfoViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/10/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapOverlayStore.h"

#import "OverlayViewController.h"
#import "ForcedNavbarViewController.h"

@interface GroundOverlayInfoViewController : ForcedNavbarViewController
@property GroundOverlay *overlay;

@end
