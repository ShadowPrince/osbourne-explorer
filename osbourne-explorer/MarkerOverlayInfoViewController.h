//
//  MarkerInfoViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/12/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapOverlayStore.h"

#import "ForcedNavbarViewController.h"
#import "OverlayViewController.h"

@interface MarkerOverlayInfoViewController : ForcedNavbarViewController
@property MarkerOverlay *marker;
@end
