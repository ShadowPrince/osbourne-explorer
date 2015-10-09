//
//  GroundOverlayTableViewCell.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/9/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapOverlayStore.h"

@interface MapOverlayTableViewCell : UITableViewCell

- (void) populate:(MapOverlay *) overlay settings:(MapOverlaySettings *) settings;

@end
