//
//  GroundOverlayFileSelectionViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/20/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "GroundOverlayFileSelectionViewController.h"

#define ImageArrayFullPath 0
#define ImageArrayFilename 1
#define ImageArrayFilesize 2
#define ImageArrayDimensions 3

@interface GroundOverlayFileSelectionViewController ()
@property NSMutableArray *images;
@property NSOperationQueue *queue;
@property IBOutlet UITableView *table;
@end@implementation GroundOverlayFileSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.nxEV_emptyView = [self.storyboard instantiateViewControllerWithIdentifier:@"fileSelectionEmptyTable"].view;
    self.table.nxEV_hideSeparatorLinesWhenShowingEmptyView = YES;

    [self updateImagesArray];
}

#pragma mark - files

- (void) updateImagesArray {
    NSLog(@"Using %@ as base path.", [DocumentsDirectory documentsDirectoryPath]);
    self.images = [NSMutableArray new];

    for (NSString *filename in [[NSFileManager defaultManager] enumeratorAtPath:[DocumentsDirectory documentsDirectoryPath]]) {
        if ([filename hasPrefix:@"."] || [filename isEqualToString:@"database.overlays"] || [filename isEqualToString:@"database.overlay-settings"])
            continue;

        NSString *path = [DocumentsDirectory pathFor:[@"/" stringByAppendingString:filename]];

        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        CGSize size = [DGFastImageSize sizeOfImageFileAtPath:path];

        NSString *humanSize = [NSByteCountFormatter stringFromByteCount:[(NSNumber *) attrs[NSFileSize] unsignedLongLongValue] countStyle:NSByteCountFormatterCountStyleFile];
        NSString *stringSize = [NSString stringWithFormat:@"%dx%dpx", (int) size.width, (int) size.height];

        [self.images addObject:@[path,
                                 filename,
                                 humanSize,
                                 stringSize, ]];
    }

    [self.table reloadData];

    NSOperationQueue *thumbs_queue = [NSOperationQueue new];
    NSMutableArray *images_to_thumbnail = self.images.mutableCopy;

    __weak GroundOverlayFileSelectionViewController *_self = self;
    __block void (^operation)() = ^(void) {
        if (images_to_thumbnail.count != 0) {
            NSArray *image = images_to_thumbnail.firstObject;
            [images_to_thumbnail removeObjectAtIndex:0];

            NSString *thumb_path = [_self thumbnailPathFor:image];
            if (![[NSFileManager defaultManager] fileExistsAtPath:thumb_path isDirectory:NO]) {
                UIImage *img = [UIImage imageWithContentsOfFile:image[ImageArrayFullPath]];
                UIImage *thumbnail = [img imageByScalingProportionallyToSize:CGSizeMake(100, 100)];
                [UIImageJPEGRepresentation(thumbnail, 70.0) writeToFile:thumb_path atomically:YES];

                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_self didGeneratedThumbnailFor:[_self.images indexOfObject:image]];
                }];
            }

            [NSThread sleepForTimeInterval:3.0];
            operation();
        }
    };
    
    [thumbs_queue addOperationWithBlock:operation];
}

- (void) deleteImage:(NSArray *) imageArray {
    NSError *e;
    [[NSFileManager defaultManager] removeItemAtPath:imageArray[ImageArrayFullPath] error:&e];
    [[NSFileManager defaultManager] removeItemAtPath:[self thumbnailPathFor:imageArray] error:nil];

    if (!e) {
        [self.images removeObject:imageArray];
        [self.table reloadData];
    } else {
        [RMUniversalAlert showAlertInViewController:self
                                          withTitle:NSLocalizedString(@"Error", @"file selection delete error")
                                            message:[NSString stringWithFormat:@"%@\n%@", e.localizedDescription, e.localizedFailureReason]
                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"file selection delete error")
                             destructiveButtonTitle:nil
                                  otherButtonTitles:nil
                                           tapBlock:nil];
    }
}

#pragma mark thumbnails

- (void) didGeneratedThumbnailFor:(NSUInteger) idx {
    [self.table reloadData];
}

- (NSString *) thumbnailPathFor:(NSArray *) image {
    NSString *thumb_name = [NSString stringWithFormat:@"/.thumb_%@.jpg", image[ImageArrayFilename]];
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

    [(UILabel *) [cell viewWithTag:200] setText:file[ImageArrayFilename]];
    [(UILabel *) [cell viewWithTag:201] setText:file[ImageArrayFilesize]];
    [(UILabel *) [cell viewWithTag:202] setText:file[ImageArrayDimensions]];

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

    [self performSegueWithIdentifier:@"positioningStage" sender:image[ImageArrayFilename]];
}

- (NSArray<UITableViewRowAction *> *) tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                            title:NSLocalizedString(@"Delete", @"fileselection table action")
                                                                          handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                              [self deleteImage:self.images[indexPath.row]];
                                                                          }];
    deleteAction.backgroundColor = [UIColor redColor];

    return @[deleteAction, ];
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
