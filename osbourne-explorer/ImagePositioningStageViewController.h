//
//  ImagePositioningStageViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/14/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "PositioningStageViewController.h"
#import "ImagePositioningView.h"

@interface ImagePositioningStageViewController : PositioningStageViewController <UIScrollViewDelegate, ImagePositioningViewDelegate>
@property (nonatomic) UIImage *image;

@end
