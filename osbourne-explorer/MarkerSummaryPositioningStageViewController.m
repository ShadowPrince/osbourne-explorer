//
//  TextFieldPositioningStageViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/20/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MarkerSummaryPositioningStageViewController.h"

@interface MarkerSummaryPositioningStageViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *iconsCollectionView;

@property NSArray<NSString *> *iconNames;
@property NSMutableArray<UIImage *> *icons;
@end@implementation MarkerSummaryPositioningStageViewController

- (void) viewDidLoad {
    if (self.defaultName)
        self.nameTextField.text = self.defaultName;

    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.delegate = self;

    self.iconNames = @[@"marker_icon", @"green_marker", @"red_marker", @"yellow_marker", @"violet_marker", ];
    self.markerIconNameValue = self.iconNames.firstObject;

    self.icons = [NSMutableArray new];
    [self.iconNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.icons addObject:[UIImage imageNamed:obj]];
    }];

    self.iconsCollectionView.allowsMultipleSelection = NO;

}

- (NSString *) nameValue {
    return self.nameTextField.text;
}

- (NSArray<NSString *> *) validationErrors {
    return nil;
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

#pragma mark - collection view

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.markerIconNameValue = self.iconNames[indexPath.row];

    for (int i = 0; i < self.icons.count; i++) {
        [[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] setBackgroundColor:[UIColor whiteColor]];
    }

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = cell.tintColor;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.icons.count;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    [(UIImageView *) [cell viewWithTag:100] setImage:self.icons[indexPath.row]];

    return cell;
}

@end
