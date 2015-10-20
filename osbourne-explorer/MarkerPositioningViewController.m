//
//  MarkerPositioningViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/13/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "MarkerPositioningViewController.h"

@interface MarkerPositioningViewController ()
@property GMSCameraPosition *mapStageSharedCamera;
@property UIImage *image;
@property NSOperationQueue *queue;
@property RMUniversalAlert *alert;
@end@implementation MarkerPositioningViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.queue = [NSOperationQueue new];
    UIImage *img = [UIImage imageNamed:@"example"];
    self.image = img;

    ImagePositioningStageViewController *i1 = [self.storyboard instantiateViewControllerWithIdentifier:@"imagePositioningStage"];
    ImagePositioningStageViewController *i2 = [self.storyboard instantiateViewControllerWithIdentifier:@"imagePositioningStage"];
    [i1 setImage:img];
    [i2 setImage:img];

    self.stages = @[i1,
                    [self.storyboard instantiateViewControllerWithIdentifier:@"mapPositioningStage"],
                    i2,
                    [self.storyboard instantiateViewControllerWithIdentifier:@"mapPositioningStage"],];
    [self.stages[0] movePositionAbsolute:CLLocationCoordinate2DMake(2000, 1000.0)];
    [self.stages[1] movePositionAbsolute:CLLocationCoordinate2DMake(51.265087381806666, 32.549720518290997)];
    [self.stages[2] movePositionAbsolute:CLLocationCoordinate2DMake(2405, 2424)];
    [self.stages[3] movePositionAbsolute:CLLocationCoordinate2DMake(51.261464194422324, 32.564449198544025)];
    [self didFinishedPositioning];
}

- (void) didCanceledPositioning {
    //
}

- (void) didFinishedPositioning {
    self.alert = (RMUniversalAlert *) [RMUniversalAlert showAlertInViewController:self
                                                                         withTitle:@"Loading..."
                                                                           message:@""
                                                                 cancelButtonTitle:nil
                                                            destructiveButtonTitle:nil
                                                                 otherButtonTitles:nil
                                                                          tapBlock:nil];
    [self.alert presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"progressbar"]];

    [self.queue addOperationWithBlock:^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];

        // original points
        CLLocationCoordinate2D mapP1 = self.stages[1].absolutePosition;
        CLLocationCoordinate2D mapP2 = self.stages[3].absolutePosition;
        CLLocationCoordinate2D imgP1 = self.stages[0].absolutePosition;
        CLLocationCoordinate2D imgP2 = self.stages[2].absolutePosition;

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

        NSString *filename = [NSString stringWithFormat:@"/._%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]];
        NSString *path = [documentsDirectory stringByAppendingString:filename];
        [UIImagePNGRepresentation(rotated_image) writeToFile:path atomically:YES];

        GroundOverlay *overlay = [GroundOverlay new];
        overlay.imageSrc = filename;
        overlay.title = @"added overlay";
        overlay.lon1 = mapP1.longitude - rotatedImgP1.longitude * rotated_scale;
        overlay.lat1 = mapP1.latitude - (rotatedImageSize.height - rotatedImgP1.latitude) * rotated_scale;
        overlay.lon2 = overlay.lon1 + rotatedImageSize.width * rotated_scale;
        overlay.lat2 = overlay.lat1 + rotatedImageSize.height * rotated_scale;
        overlay.bearing = 0;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[MapOverlayStore sharedInstance] insertMapOverlay:overlay];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self performSegueWithIdentifier:@"unwind" sender:nil];
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

- (NSArray<NSString *> *) validationErrors {
    //@TODO: check for invalid points
    return nil;
}

@end
