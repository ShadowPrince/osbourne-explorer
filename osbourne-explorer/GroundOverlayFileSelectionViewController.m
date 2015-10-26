//
//  GroundOverlayFileSelectionViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/20/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "GroundOverlayFileSelectionViewController.h"

@interface GroundOverlayFileSelectionViewController ()
@property NSMutableArray *images;
@property NSOperationQueue *queue;
@property IBOutlet UITableView *table;
@end@implementation GroundOverlayFileSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = [NSMutableArray new];

    NSLog(@"Using %@ as base path.", [DocumentsDirectory documentsDirectoryPath]);
    for (NSString *filename in [[NSFileManager defaultManager] enumeratorAtPath:[DocumentsDirectory documentsDirectoryPath]]) {
        if ([filename hasPrefix:@"."] || [filename isEqualToString:@"database.overlays"] || [filename isEqualToString:@"database.overlay-settings"])
            continue;

        NSString *path = [DocumentsDirectory pathFor:[@"/" stringByAppendingString:filename]];

        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        CGSize size = [DGFastImageSize sizeOfImageFileAtPath:path];

        NSString *humanSize = [NSByteCountFormatter stringFromByteCount:[(NSNumber *) attrs[NSFileSize] unsignedLongLongValue] countStyle:NSByteCountFormatterCountStyleFile];
        NSString *stringSize = [NSString stringWithFormat:@"%dx%dpx", (int) size.width, (int) size.height];

        [self.images addObject:@[path, filename, humanSize, stringSize, ]];
    }

    NSOperationQueue *thumbs_queue = [NSOperationQueue new];
    NSMutableArray *images_to_thumbnail = self.images.mutableCopy;

    __block void (^operation)() = ^(void) {
        if (images_to_thumbnail.count != 0) {
            NSArray *image = images_to_thumbnail.firstObject;
            [images_to_thumbnail removeObjectAtIndex:0];

            NSString *thumb_path = [self thumbnailPathFor:image];
            if (![[NSFileManager defaultManager] fileExistsAtPath:thumb_path isDirectory:NO]) {
                UIImage *img = [UIImage imageWithContentsOfFile:image[0]];
                UIImage *thumbnail = [img imageByScalingProportionallyToSize:CGSizeMake(100, 100)];
                [UIImageJPEGRepresentation(thumbnail, 70.0) writeToFile:thumb_path atomically:YES];

                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self didGeneratedThumbnailFor:[self.images indexOfObject:image]];
                }];
            }

            [NSThread sleepForTimeInterval:3.0];
            operation();
        }
    };

    [thumbs_queue addOperationWithBlock:operation];
}

- (void) didGeneratedThumbnailFor:(NSUInteger) idx {
    [self.table reloadData];
}

- (NSString *) thumbnailPathFor:(NSArray *) image {
    NSString *thumb_name = [NSString stringWithFormat:@"/.thumb_%@.jpg", image[1]];
    NSString *thumb_path = [DocumentsDirectory pathFor:thumb_name];
    return thumb_path;
}

#pragma mark - table view
#pragma mark datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *file = self.images[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    [(UILabel *) [cell viewWithTag:200] setText:file[1]];
    [(UILabel *) [cell viewWithTag:201] setText:file[2]];
    [(UILabel *) [cell viewWithTag:202] setText:file[3]];

    NSString *thumb_path = [self thumbnailPathFor:file];
    if ([[NSFileManager defaultManager] fileExistsAtPath:thumb_path isDirectory:NO]) {
        [(UIActivityIndicatorView *) [cell viewWithTag:101] stopAnimating];
        [(UIImageView *) [cell viewWithTag:100] setImage:[UIImage imageWithContentsOfFile:thumb_path]];
    } else {
        [(UIActivityIndicatorView *) [cell viewWithTag:101] startAnimating];
        [(UIImageView *) [cell viewWithTag:100] setImage:nil];
    }

    return cell;
}

#pragma mark delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *image = self.images[indexPath.row];

    [self performSegueWithIdentifier:@"positioningStage" sender:image[1]];
}

#pragma mark - segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"positioningStage"]) {
        [(GroundOverlayPositioningViewController *) segue.destinationViewController setImageName:sender];
    }

    [super prepareForSegue:segue sender:sender];
}

- (IBAction)unwindFromPositioning:(UIStoryboardSegue *)sender {
    
}

@end
