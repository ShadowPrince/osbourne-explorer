//
//  MarkerPositioningViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "GroundOverlayPositioningViewController.h"

@interface GroundOverlayPositioningViewController ()
@property GMSCameraPosition *mapStageSharedCamera;
@property UIImage *image;
@property NSOperationQueue *queue;
@property RMUniversalAlert *alert;
@end@implementation GroundOverlayPositioningViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.queue = [NSOperationQueue new];
}

- (void) didReceiveMemoryWarning {
    if (self.currentStageIndex > 0) {
        [self removeStageAtIndex:0];
    } else {
        [RMUniversalAlert showAlertInViewController:self
                                          withTitle:NSLocalizedString(@"Error", @"PVC error")
                                            message:NSLocalizedString(@"Image is too big for positioning. Try following:\n - restart app\n - resize image to make it smaller", @"PVC error")
                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"PVC error button")
                             destructiveButtonTitle:nil
                                  otherButtonTitles:nil
                                           tapBlock:^(RMUniversalAlert * _Nonnull alert, NSInteger buttonIndex) {
                                               [self abortPositioning];
                                           }];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [[RMUniversalAlert showAlertInViewController:self
                                      withTitle:@"Loading..."
                                        message:@""
                              cancelButtonTitle:nil
                         destructiveButtonTitle:nil
                              otherButtonTitles:nil
                                       tapBlock:nil]
     presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"progressbar"]];

    [self.queue addOperationWithBlock:^{
        ImageResizingStageViewController *rs = [self.storyboard instantiateViewControllerWithIdentifier:@"imageResizingStage"];
        rs.image = [UIImage imageWithContentsOfFile:[DocumentsDirectory pathFor:[@"/" stringByAppendingString:self.imageName]]];
        GroundOverlaySummaryPositioningStageViewController *namePSVC = [self.storyboard instantiateViewControllerWithIdentifier:@"groundOverlaySummaryPositioningStage"];
        namePSVC.defaultName = self.imageName;

        self.stages = @[rs,
                        [self.storyboard instantiateViewControllerWithIdentifier:@"imagePositioningStage"],
                        [self.storyboard instantiateViewControllerWithIdentifier:@"mapPositioningStage"],
                        [self.storyboard instantiateViewControllerWithIdentifier:@"imagePositioningStage"],
                        [self.storyboard instantiateViewControllerWithIdentifier:@"mapPositioningStage"],
                        namePSVC,
                        ].mutableCopy;


        [NSThread sleepForTimeInterval:1.0];
        // sometimes loading is too quick

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self dismissViewControllerAnimated:YES completion:^{
                [super viewWillAppear:animated];
            }];
        }];
    }];

}

- (void) didCanceledPositioning {
}

- (void) didFinishedPositioning {
    [[RMUniversalAlert showAlertInViewController:self
                                       withTitle:@"Loading..."
                                         message:@""
                               cancelButtonTitle:nil
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:nil]
     presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"progressbar"]];

    [self.queue addOperationWithBlock:^{
        // original points

        int shift = 6 - self.stages.count;
        CLLocationCoordinate2D mapP1 = self.stages[2-shift].absolutePosition;
        CLLocationCoordinate2D mapP2 = self.stages[4-shift].absolutePosition;
        CLLocationCoordinate2D imgP1 = self.stages[1-shift].absolutePosition;
        CLLocationCoordinate2D imgP2 = self.stages[3-shift].absolutePosition;

        // vectors & scale
        struct Vector mapVector = makeVector(mapP1, mapP2);
        struct Vector imageVector = makeVector(imgP1, imgP2);

        // rotation calculation
        double map_angle = angleBetweenVectors(mapVector, makeVector(mapP1, CLLocationCoordinate2DMake(mapP1.latitude, mapP1.longitude + 100.0)));
        double img_angle = -angleBetweenVectors(imageVector, makeVector(imgP1, CLLocationCoordinate2DMake(imgP1.latitude, imgP1.longitude + 100.0)));
        double rad_angle = map_angle - img_angle;

        // image rotation
        UIImage *rotated_image = [self.image imageRotatedByRadians:rad_angle];
        CGSize rotatedImageSize = rotated_image.size;
        CGPoint rotatedSizeDelta = CGPointMake(rotatedImageSize.width - self.image.size.width, rotatedImageSize.height - self.image.size.height);

        // rotating vectors
        CLLocationCoordinate2D imageCenterP = CLLocationCoordinate2DMake(self.image.size.height / 2, self.image.size.width / 2);
        struct Vector vector1, vector2;
        vector1 = makeVector(imageCenterP, imgP1);
        vector2 = makeVector(imageCenterP, imgP2);
        vector1 = rotateVector(vector1, rad_angle);
        vector2 = rotateVector(vector2, rad_angle);
        CLLocationCoordinate2D rotatedImgP1 = CLLocationCoordinate2DMake(vector1.b.latitude + rotatedSizeDelta.y / 2, vector1.b.longitude + rotatedSizeDelta.x / 2);
        CLLocationCoordinate2D rotatedImgP2 = CLLocationCoordinate2DMake(vector2.b.latitude + rotatedSizeDelta.y / 2, vector2.b.longitude + rotatedSizeDelta.x / 2);
        struct Vector rotatedImageVector = makeVector(rotatedImgP1, rotatedImgP2);
        double rotated_scale = mapVector.length / rotatedImageVector.length;

        // saving rotated image
        NSString *filename = [NSString stringWithFormat:@"/._%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]];
        NSString *path = [DocumentsDirectory pathFor:filename];
        [UIImagePNGRepresentation(rotated_image) writeToFile:path atomically:YES];

        // info
        GroundOverlaySummaryPositioningStageViewController *nameController = (GroundOverlaySummaryPositioningStageViewController *) self.stages.lastObject;

        GroundOverlay *overlay = [GroundOverlay new];
        overlay.imageSrc = filename;
        overlay.title = nameController.nameValue;
        overlay.lon1 = mapP1.longitude - rotatedImgP1.longitude * rotated_scale;
        overlay.lat1 = mapP1.latitude - (rotatedImageSize.height - rotatedImgP1.latitude) * rotated_scale;
        overlay.lon2 = overlay.lon1 + rotatedImageSize.width * rotated_scale;
        overlay.lat2 = overlay.lat1 + rotatedImageSize.height * rotated_scale;
        overlay.bearing = 0;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[MapOverlayStore sharedInstance] insertMapOverlay:overlay];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self performSegueWithIdentifier:@"finishUnwind" sender:nil];
            }];
        }];
    }];

}

- (void) didMovedFrom:(PositioningStageViewController *)prev to:(PositioningStageViewController *)current {
    [super didMovedFrom:prev to:current];

    if ([prev isKindOfClass:[MapPositioningStageViewController class]]) {
        self.mapStageSharedCamera = [(MapPositioningStageViewController *) prev camera];
    }

    if ([current isKindOfClass:[MapPositioningStageViewController class]]) {
        [(MapPositioningStageViewController *) current setCamera:self.mapStageSharedCamera];
    }
}

- (void) willMoveFrom:(PositioningStageViewController *)prev to:(PositioningStageViewController *)current {
    [super willMoveFrom:prev to:current];


    if ([prev isKindOfClass:[ImageResizingStageViewController class]]) {
        ImageResizingStageViewController *stage = (ImageResizingStageViewController *) prev;

        [[RMUniversalAlert showAlertInViewController:self
                                           withTitle:@"Loading..."
                                             message:@""
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil
                                            tapBlock:nil]
         presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"progressbar"]];
        [self.queue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:1.0];
            self.image = [stage.image imageCroppedBy:stage.targetRect];

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self dismissViewControllerAnimated:YES completion:^{
                    if ([current isKindOfClass:[ImagePositioningStageViewController class]]) {
                        [(ImagePositioningStageViewController *) current setImage:self.image];
                    }
                }];
            }];
        }];
    }

    if ([current isKindOfClass:[ImagePositioningStageViewController class]]) {
        [(ImagePositioningStageViewController *) current setImage:self.image];
    }
}

- (NSArray<NSString *> *) validationErrors {
    //@TODO: check for invalid points
    return nil;
}

@end
