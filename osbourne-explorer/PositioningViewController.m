//
//  PositioningViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#define CURSOR_STEP 0.000002

#import "PositioningViewController.h"

@interface PositioningViewController ()
@property NSUInteger stageIdx;
@property PositioningStageViewController *activePSVC;
//---
@property IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property IBOutlet UIView *stageView;
@property IBOutlet UIButton *prevButton, *nextButton;
@property IBOutlet UITextField *activePointXTextField, *activePointYTextField;
@property IBOutlet UILabel *activePSVCTitleLabel;
@end@implementation PositioningViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.stageIdx = 0;

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

- (void) didFinishedPositioning {
    @throw [NSError errorWithDomain:@"abstract method call" code:0 userInfo:0];
}

- (void) presentStageAt:(NSUInteger) idx {
    if (self.activePSVC) {
        self.activePSVC.delegate = nil;
        [self.activePSVC willMoveToParentViewController:nil];
        [self.activePSVC.view removeFromSuperview];
        [self.activePSVC removeFromParentViewController];
    }

    PositioningStageViewController *controller = self.stages[idx];
    [self addChildViewController:controller];
    controller.view.frame = self.stageView.frame;
    [self.stageView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    controller.delegate = self;
    self.activePSVCTitleLabel.text = [NSString stringWithFormat:@"№%d/%d: %@", idx+1, self.stages.count, controller];

    self.activePSVC = controller;

    if (idx == 0) {
        self.prevButton.enabled = NO;
    } else {
        self.prevButton.enabled = YES;
    }

    if (idx == self.stages.count - 1) {
        [self.nextButton setTitle:NSLocalizedString(@"Finish", @"PVC button") forState:UIControlStateNormal];
    } else {
        [self.nextButton setTitle:NSLocalizedString(@"Next", @"PVC button") forState:UIControlStateNormal];
    }
}

#pragma mark - stage delegate

- (void) didMovePositionTo:(CGPoint)p {
    self.activePointXTextField.text = [NSString stringWithFormat:@"%f", p.x];
    self.activePointYTextField.text = [NSString stringWithFormat:@"%f", p.y];
}

#pragma mark - actions
#pragma mark next/prev
- (IBAction)backButtonAction:(id)sender {
    if (self.stageIdx > 0) {
        self.stageIdx--;
        [self presentStageAt:self.stageIdx];
    }
}

- (IBAction)nextButtonAction:(id)sender {
    if ([self.activePSVC isValid]) {
        if (self.stageIdx < self.stages.count - 1) {
            self.stageIdx++;
            [self presentStageAt:self.stageIdx];
        } else {
            [RMUniversalAlert showActionSheetInViewController:self
                                                    withTitle:NSLocalizedString(@"Notice", @"PVC finish alert")
                                                      message:NSLocalizedString(@"Are you sure you want to finish positioning?", @"PVC finish alert")
                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"PVC finish alert")
                                       destructiveButtonTitle:@"proceed"
                                            otherButtonTitles:nil
                           popoverPresentationControllerBlock:nil
                                                     tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {

                                                     }];
        }
    } else {
         [RMUniversalAlert showAlertInViewController:self
                                          withTitle:NSLocalizedString(@"Error", @"alert")
                                            message:NSLocalizedString(@"Select point", @"alert")
                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"alert")
                             destructiveButtonTitle:nil
                                  otherButtonTitles:nil
                                           tapBlock:nil];
    }
}

#pragma mark cursor movement
- (IBAction)upButtonAction:(id)sender {
    [self.activePSVC movePositionRelative:CGPointMake(0, CURSOR_STEP)];
}
- (IBAction)downButtonAction:(id)sender {
    [self.activePSVC movePositionRelative:CGPointMake(0, -CURSOR_STEP)];
}
- (IBAction)righButtonAction:(id)sender {
    [self.activePSVC movePositionRelative:CGPointMake(CURSOR_STEP, 0)];
}
- (IBAction)leftButtonAction:(id)sender {
    [self.activePSVC movePositionRelative:CGPointMake(-CURSOR_STEP, 0)];
}

#pragma mark coordinate textfields
- (IBAction)activePointTextfieldsChange:(UITextField *)sender {
    [self.activePSVC movePositionAbsolute:[self pointFromTextfields]];
}

#pragma mark - helper methods
- (CGPoint) pointFromTextfields {
    return CGPointMake(self.activePointXTextField.text.doubleValue, self.activePointYTextField.text.doubleValue);
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
