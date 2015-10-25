//
//  PositioningViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#define CURSOR_STEP 1

#import "PositioningViewController.h"

@interface PositioningViewController ()
@property NSUInteger stageIdx;
@property PositioningStageViewController *activePSVC;
//---
@property IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property IBOutlet NSLayoutConstraint *controlBarHeightConstraint;

@property CGFloat textFieldsHeight, controlBarHeight;
@property NSArray<NSLayoutConstraint *> *textFieldHeightConstraints;
@property NSArray<UIView *> *cursorButtons;
@property IBOutlet UIView *stageView;
@property IBOutlet UIButton *prevButton, *nextButton;
@property IBOutlet UITextField *activePointXTextField, *activePointYTextField;
@property IBOutlet UILabel *activePSVCTitleLabel;
@end@implementation PositioningViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.stageIdx = 0;
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.controlBarHeight = 223.f;
        self.controlBarHeightConstraint.constant = self.controlBarHeight;
    } else {
        self.controlBarHeight = self.controlBarHeightConstraint.constant;
    }

    // binding control buttons

    UIView *paneView = [(UIViewController *) self.childViewControllers.lastObject view];
    UIButton *b = nil;
    b = [paneView viewWithTag:100];
    [b addTarget:self action:@selector(upButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    b = [paneView viewWithTag:101];
    [b addTarget:self action:@selector(righButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    b = [paneView viewWithTag:102];
    [b addTarget:self action:@selector(downButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    b = [paneView viewWithTag:103];
    [b addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    b = [paneView viewWithTag:200];
    self.prevButton = b;
    [b addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    b = [paneView viewWithTag:201];
    self.nextButton = b;
    [b addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    self.activePSVCTitleLabel = [paneView viewWithTag:400];

    self.activePointXTextField = [paneView viewWithTag:300];
    self.activePointYTextField = [paneView viewWithTag:301];
    self.activePointXTextField.returnKeyType = UIReturnKeyDone;
    self.activePointYTextField.returnKeyType = UIReturnKeyDone;
    self.activePointXTextField.delegate = self;
    self.activePointYTextField.delegate = self;

    self.textFieldsHeight = [paneView viewWithTag:300].constraints.firstObject.constant;
    self.textFieldHeightConstraints = @[[paneView viewWithTag:300].constraints.firstObject,
                                        [paneView viewWithTag:301].constraints.firstObject, ];
    self.cursorButtons = @[[paneView viewWithTag:100],
                           [paneView viewWithTag:101],
                           [paneView viewWithTag:102],
                           [paneView viewWithTag:103], ];

    [self.activePointXTextField addTarget:self action:@selector(activePointTextfieldsChange:) forControlEvents:UIControlEventEditingDidEnd];
    [self.activePointYTextField addTarget:self action:@selector(activePointTextfieldsChange:) forControlEvents:UIControlEventEditingChanged];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [self presentStageAt:self.stageIdx];
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void) didFinishedPositioning {
    @throw [NSError errorWithDomain:@"abstract method call" code:0 userInfo:0];
}

- (void) didCanceledPositioning {
    @throw [NSError errorWithDomain:@"abstract method call" code:0 userInfo:0];
}

- (void) willMoveFrom:(PositioningStageViewController *)c1 to:(PositioningStageViewController *)p2 {}
- (void) didMovedFrom:(PositioningStageViewController *)prev to:(PositioningStageViewController *)current {}
- (NSArray<NSString *> *) validationErrors {
    return nil;
}

- (void) presentStageAt:(NSUInteger) idx {
    if (self.activePSVC) {
        self.activePSVC.delegate = nil;
        [self.activePSVC willMoveToParentViewController:nil];
        [self.activePSVC.view removeFromSuperview];
        [self.activePSVC removeFromParentViewController];
    }

    PositioningStageViewController *controller = self.stages[idx];
    [self willMoveFrom:self.activePSVC to:controller];

    [self addChildViewController:controller];
    controller.view.frame = self.stageView.frame;
    [self.stageView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    controller.delegate = self;
    [self updateActivePositioningControllerTitleAt:idx+1 for:controller];

    [self didMovedFrom:self.activePSVC to:controller];
    self.activePSVC = controller;

    for (NSLayoutConstraint *constraint in self.textFieldHeightConstraints) {
        if (self.activePSVC.prefersControlBarHidden) {
            constraint.constant = 0.f;
        } else {
            constraint.constant = self.textFieldsHeight;
        }
    }

    for (UIView *view in self.cursorButtons) {
        view.hidden = self.activePSVC.prefersControlBarHidden;
    }

    if (self.activePSVC.prefersControlBarHidden) {
        self.controlBarHeightConstraint.constant = self.controlBarHeight / 1.5;
    } else {
        self.controlBarHeightConstraint.constant = self.controlBarHeight;
    }

    [self.view setNeedsLayout];

    if (idx == 0) {
        [self.prevButton setTitle:NSLocalizedString(@"Abort", @"PVC button") forState:UIControlStateNormal];
    } else {
        [self.prevButton setTitle:NSLocalizedString(@"Back", @"PVC button") forState:UIControlStateNormal];
    }

    if (idx == self.stages.count - 1) {
        [self.nextButton setTitle:NSLocalizedString(@"Finish", @"PVC button") forState:UIControlStateNormal];
    } else {
        [self.nextButton setTitle:NSLocalizedString(@"Next", @"PVC button") forState:UIControlStateNormal];
    }

    self.activePointXTextField.text = @"";
    self.activePointYTextField.text = @"";
}

- (void) removeStageAtIndex:(NSUInteger)idx {
    if (self.stageIdx < idx)
        self.stageIdx--;

    [self.stages removeObjectAtIndex:idx];
    [self updateActivePositioningControllerTitleAt:self.stageIdx for:self.activePSVC];
}

- (NSUInteger) currentStageIndex {
    return self.stageIdx;
}

- (void) abortPositioning {
    [self abortAction];
}

#pragma mark - stage delegate

- (void) didMovePositionTo:(CLLocationCoordinate2D)p {
    self.activePointXTextField.text = [NSString stringWithFormat:@"%f", p.longitude];
    self.activePointYTextField.text = [NSString stringWithFormat:@"%f", p.latitude];
}

#pragma mark - actions
#pragma mark next/prev
- (IBAction)backButtonAction:(id)sender {
    if (self.stageIdx > 0) {
        self.stageIdx--;
        [self presentStageAt:self.stageIdx];
    } else {
        [RMUniversalAlert showActionSheetInViewController:self
                                                withTitle:NSLocalizedString(@"Notice", @"PVC finish alert")
                                                  message:NSLocalizedString(@"Are you sure you want to abort positioning?", @"PVC cancel alert")
                                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"PVC finish alert")
                                   destructiveButtonTitle:NSLocalizedString(@"Abort", @"PVC finish alert")
                                        otherButtonTitles:nil
                                              popoverRect:CGRectMake(10, self.view.frame.size.height - 10, 0, 0)
                       popoverPresentationControllerBlock:nil
                                                 tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
                                                     if (buttonIndex == alert.destructiveButtonIndex) {
                                                         [self abortAction];
                                                     }
                                                 }];
    }
}

- (IBAction)nextButtonAction:(id)sender {
    if (![self.activePSVC isValid]) {
        [RMUniversalAlert showAlertInViewController:self
                                          withTitle:NSLocalizedString(@"Error", @"alert")
                                            message:NSLocalizedString(@"Select point", @"alert")
                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"alert")
                             destructiveButtonTitle:nil
                                  otherButtonTitles:nil
                                           tapBlock:nil];
    } else {
        if (self.stageIdx < self.stages.count - 1) {
            self.stageIdx++;
            [self presentStageAt:self.stageIdx];
        } else {
            [RMUniversalAlert showActionSheetInViewController:self
                                                    withTitle:NSLocalizedString(@"Notice", @"PVC finish alert")
                                                      message:NSLocalizedString(@"Are you sure you want to finish positioning?", @"PVC finish alert")
                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"PVC finish alert")
                                       destructiveButtonTitle:NSLocalizedString(@"Proceed", @"PVC finish alert")
                                            otherButtonTitles:nil
                                                  popoverRect:CGRectMake(self.view.frame.size.width - 10, self.view.frame.size.height - 10, 0, 0)
                           popoverPresentationControllerBlock:nil
                                                     tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
                                                         if (buttonIndex == alert.destructiveButtonIndex) {
                                                             [self finishAction];
                                                         }
                                                     }];
        }
    }
}

- (void) finishAction {
    NSArray<NSString *> *errors = self.validationErrors;

    if (!errors) {
        [self didFinishedPositioning];
    } else {
        [RMUniversalAlert showAlertInViewController:self
                                          withTitle:NSLocalizedString(@"Error", @"alert")
                                            message:[errors componentsJoinedByString:@"\n"]
                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"alert")
                             destructiveButtonTitle:nil
                                  otherButtonTitles:nil
                                           tapBlock:nil];
    }

}

- (void) abortAction {
    [self didCanceledPositioning];
    [self performSegueWithIdentifier:@"abortUnwind" sender:self];
}

#pragma mark cursor movement
- (IBAction)upButtonAction:(id)sender {
    [self.activePSVC movePositionRelative:CLLocationCoordinate2DMake(-CURSOR_STEP, 0)];
}
- (IBAction)downButtonAction:(id)sender {
    [self.activePSVC movePositionRelative:CLLocationCoordinate2DMake(CURSOR_STEP, 0)];
}
- (IBAction)righButtonAction:(id)sender {
    [self.activePSVC movePositionRelative:CLLocationCoordinate2DMake(0, -CURSOR_STEP)];
}
- (IBAction)leftButtonAction:(id)sender {
    [self.activePSVC movePositionRelative:CLLocationCoordinate2DMake(0, +CURSOR_STEP)];
}

#pragma mark coordinate textfields
- (IBAction)activePointTextfieldsChange:(UITextField *)sender {
    [self.activePSVC movePositionAbsolute:[self pointFromTextfields]];
}

#pragma mark - helper methods
- (CLLocationCoordinate2D) pointFromTextfields {
    return CLLocationCoordinate2DMake(self.activePointYTextField.text.doubleValue, self.activePointXTextField.text.doubleValue);
}

- (void) updateActivePositioningControllerTitleAt:(NSUInteger) idx for:(PositioningStageViewController *) controller {
    self.activePSVCTitleLabel.text = [NSString stringWithFormat:@"№%d/%d: %@", idx, self.stages.count, controller];
}

#pragma mark - keyboard

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.bottomLayoutConstraint.constant = kbSize.height;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    self.bottomLayoutConstraint.constant = 0.f;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
