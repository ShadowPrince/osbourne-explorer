//
//  ImageResizingStageViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/22/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIImage-Extensions.h"

#import "PositioningStageViewController.h"

@interface ImageResizingStageViewController : PositioningStageViewController <UIScrollViewDelegate>
@property (nonatomic) UIImage *image;
@property UIImage *resizedImage;

- (CGRect) targetRect;

@end
