//
//  ImageResizingStageViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/22/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "ImageResizingStageViewController.h"

@interface ImageResizingStageViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end@implementation ImageResizingStageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.imageView.image = self.image;
    self.scrollView.zoomScale = self.scrollView.frame.size.width / self.image.size.width;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (NSArray<NSString *> *) validationErrors {
    CGRect targetRect = self.targetRect;

    int px = targetRect.size.width * targetRect.size.height;
    if ([SettingsController restrictionsEnabled] && px > 1500*1500) {
        return @[NSLocalizedString(@"Resized image is too big, select smaller area", @"ImageResizing SVC error")];
    } else {
        return nil;
    }
}

- (void) setContentInset:(UIEdgeInsets)inset {
    self.scrollView.contentInset = inset;
}

- (CGRect) targetRect {
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGSize scrollViewSize = self.scrollView.frame.size;
    CGFloat scale = self.image.size.width / self.scrollView.contentSize.width;

    CGRect targetRect = CGRectMake(contentOffset.x * scale,
                                   contentOffset.y * scale,
                                   scrollViewSize.width * scale,
                                   scrollViewSize.height * scale);

    return targetRect;
}

- (NSString *) description {
    return NSLocalizedString(@"Select image area to use", @"ImageResizingStage description");
}

- (void) dealloc {
    self.imageView.image = nil;
    self.image = nil;
}

- (BOOL) prefersControlBarHidden {
    return YES;
}

@end
