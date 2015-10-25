//
//  RMUniversalAlert.m
//  RMUniversalAlert
//
//  Created by Ryan Maxwell on 19/11/14.
//  Copyright (c) 2014 Ryan Maxwell. All rights reserved.
//

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

#import "RMUniversalAlert.h"

static NSInteger const RMUniversalAlertNoButtonExistsIndex = -1;

static NSInteger const RMUniversalAlertCancelButtonIndex = 0;
static NSInteger const RMUniversalAlertDestructiveButtonIndex = 1;
static NSInteger const RMUniversalAlertFirstOtherButtonIndex = 2;

@interface RMUniversalAlert ()

@property (nonatomic, assign) BOOL hasCancelButton;
@property (nonatomic, assign) BOOL hasDestructiveButton;
@property (nonatomic, assign) BOOL hasOtherButtons;

@end

@implementation RMUniversalAlert

+ (instancetype)showAlertInViewController:(UIViewController *)viewController
                                withTitle:(NSString *)title
                                  message:(NSString *)message
                        cancelButtonTitle:(NSString *)cancelButtonTitle
                   destructiveButtonTitle:(NSString *)destructiveButtonTitle
                        otherButtonTitles:(NSArray *)otherButtonTitles
                                 tapBlock:(RMUniversalAlertCompletionBlock)tapBlock
{
    RMUniversalAlert *alert = [[RMUniversalAlert alloc] init];
    
    alert.hasCancelButton = cancelButtonTitle != nil;
    alert.hasDestructiveButton = destructiveButtonTitle != nil;
    alert.hasOtherButtons = otherButtonTitles.count > 0;

    alert.alertController = [UIAlertController showAlertInViewController:viewController
                                                               withTitle:title message:message
                                                       cancelButtonTitle:cancelButtonTitle
                                                  destructiveButtonTitle:destructiveButtonTitle
                                                       otherButtonTitles:otherButtonTitles
                                                                tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                                    if (tapBlock) {
                                                                        tapBlock(alert, buttonIndex);
                                                                    }
                                                                }];
    return alert;
}

+ (instancetype)showActionSheetInViewController:(UIViewController *)viewController
                                      withTitle:(NSString *)title
                                        message:(NSString *)message
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                              otherButtonTitles:(NSArray *)otherButtonTitles
                                    popoverRect:(CGRect)rekt
             popoverPresentationControllerBlock:(void(^)(RMPopoverPresentationController *popover))popoverPresentationControllerBlock
                                       tapBlock:(RMUniversalAlertCompletionBlock)tapBlock
{
    RMUniversalAlert *alert = [[RMUniversalAlert alloc] init];

    alert.hasCancelButton = cancelButtonTitle != nil;
    alert.hasDestructiveButton = destructiveButtonTitle != nil;
    alert.hasOtherButtons = otherButtonTitles.count > 0;

    alert.alertController = [UIAlertController showActionSheetInViewController:viewController
                                                                     withTitle:title
                                                                       message:message
                                                             cancelButtonTitle:cancelButtonTitle
                                                        destructiveButtonTitle:destructiveButtonTitle
                                                             otherButtonTitles:otherButtonTitles
                                            popoverPresentationControllerBlock:^(UIPopoverPresentationController *popover){
                                                if (popoverPresentationControllerBlock) {
                                                    RMPopoverPresentationController *configuredPopover = [RMPopoverPresentationController new];

                                                    popoverPresentationControllerBlock(configuredPopover);

                                                    popover.sourceView = configuredPopover.sourceView;
                                                    popover.sourceRect = configuredPopover.sourceRect;
                                                    popover.barButtonItem = configuredPopover.barButtonItem;
                                                }
                                            }
                                                                      tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                                          if (tapBlock) {
                                                                              tapBlock(alert, buttonIndex);
                                                                          }
                                                                      }];
    alert.alertController.popoverPresentationController.sourceView = viewController.view;
    alert.alertController.popoverPresentationController.sourceRect = rekt;

    return alert;
}

- (void) presentViewController:(UIViewController *) c expandHeightTo:(CGFloat) height {
    UIAlertController *alert = self.alertController;

    CGRect frame = alert.view.frame;
    frame.size.height *= 2;
    alert.view.frame = frame;

    CGFloat x = 10;
    CGFloat y = 40;
    c.view.frame = CGRectMake(x, y, alert.view.frame.size.width - x, alert.view.frame.size.height - y);
    [alert.view addSubview:c.view];
    [alert addChildViewController:c];

    [alert.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[x(height)]"
                                                                       options:0
                                                                       metrics:@{@"height": [NSNumber numberWithFloat:height]}
                                                                         views:@{@"x": alert.view}]];
}

- (void) presentViewController:(UIViewController *)c {
    [self presentViewController:c expandHeightTo:90.f];
}

#pragma mark -

- (BOOL)visible
{
    if (self.alertController) {
        return self.alertController.visible;
    } else if (self.alertView) {
        return self.alertView.visible;
    } else if (self.actionSheet) {
        return self.actionSheet.visible;
    }
    NSAssert(false, @"Unsupported alert.");
    return NO;
}

- (NSInteger)cancelButtonIndex
{
    if (!self.hasCancelButton) {
        return RMUniversalAlertNoButtonExistsIndex;
    }
    
    return RMUniversalAlertCancelButtonIndex;
}

- (NSInteger)firstOtherButtonIndex
{
    if (!self.hasOtherButtons) {
        return RMUniversalAlertNoButtonExistsIndex;
    }
    
    return RMUniversalAlertFirstOtherButtonIndex;
}

- (NSInteger)destructiveButtonIndex
{
    if (!self.hasDestructiveButton) {
        return RMUniversalAlertNoButtonExistsIndex;
    }
    
    return RMUniversalAlertDestructiveButtonIndex;
}

@end
