//
//  GroundOverlaySummaryPositioningStageViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/23/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "GroundOverlaySummaryPositioningStageViewController.h"

@interface GroundOverlaySummaryPositioningStageViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@end@implementation GroundOverlaySummaryPositioningStageViewController
- (void) viewDidLoad {
    if (self.defaultName)
        self.nameTextField.text = self.defaultName;

    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.delegate = self;
}

- (NSString *) nameValue {
    return self.nameTextField.text;
}

- (BOOL) isValid {
    return YES;
}

- (BOOL) prefersControlBarHidden {
    return YES;
}

- (NSString *) description {
    return NSLocalizedString(@"Specify title for overlay", @"Name field PSVC");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
