//
//  TextFieldPositioningStageViewController.h
//  osbourne-explorer
//
//  Created by shdwprince on 10/20/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "PositioningStageViewController.h"

@interface MarkerSummaryPositioningStageViewController : PositioningStageViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property NSString *defaultName;

@property NSString *markerIconNameValue;

- (NSString *) nameValue;
@end
