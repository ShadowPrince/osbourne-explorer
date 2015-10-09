//
//  GroundOverlayTableViewCell.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/9/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MapOverlayTableViewCell.h"

@interface MapOverlayTableViewCell ()
@property IBOutlet UILabel *nameLabel;
@property IBOutlet UILabel *hiddenLabel;
@property IBOutlet UILabel *semitransparentLabel;
@property IBOutlet UIImageView *iconImageView;
@end@implementation MapOverlayTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) populate:(MapOverlay *)overlay settings:(MapOverlaySettings *)settings {
    self.nameLabel.text = [overlay title];

    if (settings.hidden) {
        self.iconImageView.backgroundColor = [UIColor grayColor];
    } else if (settings.semiTransparent) {
        self.iconImageView.backgroundColor = [UIColor blueColor];
    } else {
        self.iconImageView.backgroundColor = [UIColor whiteColor];
    }

    if ([overlay isKindOfClass:[MarkerOverlay class]]) {

        MarkerOverlay *marker = (MarkerOverlay *) overlay;

        if (marker.icon) {
            self.iconImageView.image = marker.icon;
        } else {
            self.iconImageView.image = [UIImage imageNamed:@"marker_icon"];
        }
    } else if ([overlay isKindOfClass:[GroundOverlay class]]) {
        self.iconImageView.image = [UIImage imageNamed:@"overlay_icon"];
    }
}

@end
