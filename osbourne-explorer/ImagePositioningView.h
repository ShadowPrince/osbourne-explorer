//
//  ImagePositioningView.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/14/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagePositioningViewDelegate <NSObject>
- (void) didSelectedPoint:(CGPoint) p;
@end

@interface ImagePositioningView : UIImageView
@property (weak) IBOutlet NSObject<ImagePositioningViewDelegate> *delegate;

- (void) moveAbsolute:(CGPoint) p;
- (void) moveRelative:(CGPoint) p;

@end
