//
//  SettingsController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/26/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "SettingsController.h"

#define FileArrayPath 0
#define FileArrayFilename 1
#define FileArraySize 2

@interface SettingsController ()
@property (weak, nonatomic) IBOutlet UISwitch *restrictionsToggle;
@property (weak, nonatomic) IBOutlet UILabel *cleanupMeterLabel;

@end@implementation SettingsController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:@"overlay_size_restrictions"];
    [self.restrictionsToggle setOn:val];

    [self updateCleanupMeter];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    BOOL b = self.restrictionsToggle.on;
    [[NSUserDefaults standardUserDefaults] setBool:b forKey:@"overlay_size_restrictions"];
}

- (IBAction)cleanupAction:(id)sender {
    [[self cleanupFiles] enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSFileManager defaultManager] removeItemAtPath:obj[FileArrayPath] error:nil];
    }];

    [self updateCleanupMeter];
}

- (IBAction)resetAction:(id)sender {
    __weak SettingsController *_self = self;
    [RMUniversalAlert showAlertInViewController:self
                                      withTitle:NSLocalizedString(@"Confirm cleanup", @"settings cleanup alert")
                                        message:NSLocalizedString(@"Reset all content?", @"settings cleanup alert")
                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"settings cleanup alert")
                         destructiveButtonTitle:NSLocalizedString(@"Reset", @"settings cleanup alert")
                              otherButtonTitles:nil
                                       tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
                                           if (buttonIndex == alert.destructiveButtonIndex) {
                                               [[[MapOverlayStore sharedInstance] allOverlays] enumerateObjectsUsingBlock:^(MapOverlay *obj, NSUInteger idx, BOOL *stop) {
                                                   [[MapOverlayStore sharedInstance] removeMapOverlay:obj];
                                               }];

                                               [_self cleanupAction:nil];
                                           }
                                       }];
}

#pragma mark - helper

- (void) updateCleanupMeter {
    __block unsigned long long total_size = 0;

    [[self cleanupFiles] enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"cleanup %@", obj[FileArrayFilename]);
        total_size += [(NSNumber *) obj[FileArraySize] unsignedLongLongValue];
    }];

    NSString *humanSize = [NSByteCountFormatter stringFromByteCount:total_size countStyle:NSByteCountFormatterCountStyleFile];
    self.cleanupMeterLabel.text = humanSize;
}

- (NSArray<NSArray *> *) cleanupFiles {
    NSMutableArray<NSString *> *associatedImages = [NSMutableArray new];
    [[[MapOverlayStore sharedInstance] allOverlays] enumerateObjectsUsingBlock:^(MapOverlay * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[GroundOverlay class]]) {
            [associatedImages addObject:[(GroundOverlay *) obj imageSrc]];
        }
    }];

    NSMutableArray *result = [NSMutableArray new];

    for (NSString *filename in [[NSFileManager defaultManager] enumeratorAtPath:[DocumentsDirectory documentsDirectoryPath]]) {
        if (![filename hasPrefix:@"."])
            continue;

        if (![associatedImages containsObject:filename]) {
            NSString *path = [DocumentsDirectory pathFor:[@"/" stringByAppendingString:filename]];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];

            [result addObject:@[path,
                                filename,
                                (NSNumber *) attrs[NSFileSize], ]];
        }
    }

    return result;
}

#pragma mark class methods 

+ (void) sync {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"initial_setup"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"initial_setup"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"overlay_size_restrictions"];
    }
}

+ (BOOL) restrictionsEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"overlay_size_restrictions"];
}

@end
