//
//  NavigationMenuViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/9/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapOverlayStore.h"

#import "MapOverlayTableViewCell.h"

@interface NavigationMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MapOverlayStoreDelegate>

@end
