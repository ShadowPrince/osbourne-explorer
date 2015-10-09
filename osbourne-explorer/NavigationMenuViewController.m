//
//  NavigationMenuViewController.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/9/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "NavigationMenuViewController.h"

#define SECTION_GROUND_OVERLAYS 0
#define SECTION_MARKERS 1
#define SECTION_CONTROLS 2

#define CONTROLS_ADD_OVERLAY 0
#define CONTROLS_ADD_MARKER 1

@interface NavigationMenuViewController ()
@property MapOverlayStore *store;

@property IBOutlet UITableView *tableView;
@end@implementation NavigationMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.store = [MapOverlayStore sharedInstance];
    [self.store registerDelegate:self];
}

#pragma mark - store delegate

- (void) didUpdatedOverlay:(MapOverlay *)overlay {
    [self.tableView reloadRowsAtIndexPaths:@[[self indexPathOfMapOverlay:overlay]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - table view
#pragma mark datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SECTION_GROUND_OVERLAYS:
            return [self filterGroundOverlaysOfClass:[GroundOverlay class]].count;
        case SECTION_MARKERS:
            return [self filterGroundOverlaysOfClass:[MarkerOverlay class]].count;
        case SECTION_CONTROLS:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_GROUND_OVERLAYS) {
        MapOverlayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"markerCell"];
        GroundOverlay *overlay = (GroundOverlay *) [self mapOverlayOn:indexPath];

        [cell populate:overlay settings:[self.store settingsForOverlay:overlay]];
        return cell;
    } else if (indexPath.section == SECTION_MARKERS) {
        MapOverlayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"markerCell"];
        MarkerOverlay *overlay = (MarkerOverlay *) [self mapOverlayOn:indexPath];

        [cell populate:overlay settings:[self.store settingsForOverlay:overlay]];
        return cell;
    } else if (indexPath.section == SECTION_CONTROLS) {
        return [tableView dequeueReusableCellWithIdentifier:@[@"newOverlayCell", @"newMarkerCell"][indexPath.row]];
    } else {
        return nil;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[NSLocalizedString(@"Ground overlays", @"navmenu header"),
             NSLocalizedString(@"Markers", @"navmenu header"),
             NSLocalizedString(@"Actions", @"navmenu header"), ][section];
}

#pragma mark delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *sender = [self mapOverlayOn:indexPath];
    NSString *segueId = nil;

    if (indexPath.section == SECTION_GROUND_OVERLAYS) {
        segueId = @"overlayInfo";
    } else if (indexPath.section == SECTION_MARKERS) {
        segueId = @"markerInfo";
    } else {
        switch (indexPath.row) {
            case 0:
                segueId = @"newOverlay";
                break;
            case 1:
                segueId = @"newMarker";
                break;
        }
    }

    [self performSegueWithIdentifier:segueId sender:sender];
}

- (NSArray<UITableViewRowAction *> *) tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    MapOverlay *mapOverlay = [self mapOverlayOn:indexPath];
    MapOverlaySettings *overlaySettings = [self.store settingsForOverlay:mapOverlay];

    NSMutableArray<UITableViewRowAction *> *actions = [NSMutableArray new];

    if (indexPath.section == SECTION_MARKERS || indexPath.section == SECTION_GROUND_OVERLAYS) {
        NSArray *hiddenToggleTitles = @[NSLocalizedString(@"Hide", @"navmenu table action"), NSLocalizedString(@"Show", @"navmenu table action")];
        UITableViewRowAction *toggleHiddenAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                                      title:hiddenToggleTitles[overlaySettings.hidden]
                                                                                    handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                                        MapOverlay *ov = [self mapOverlayOn:indexPath];
                                                                                        MapOverlaySettings *settings = [self.store settingsForOverlay:ov];
                                                                                        settings.hidden = !settings.hidden;
                                                                                        [self.store didUpdatedOverlay:ov];
                                                                                        tableView.editing = NO;
                                                                                    }];
        toggleHiddenAction.backgroundColor = [UIColor grayColor];
        [actions addObject:toggleHiddenAction];
    }

    if (indexPath.section == SECTION_GROUND_OVERLAYS) {
        NSArray *semitransToggleTitles = @[NSLocalizedString(@"Transp.", @"navmenu table actions"), NSLocalizedString(@"Solid", @"navmenu table actions")];

        UITableViewRowAction *toggleSemitransAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                                         title:semitransToggleTitles[overlaySettings.semiTransparent]
                                                                                       handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                                           MapOverlay *ov = [self mapOverlayOn:indexPath];
                                                                                           MapOverlaySettings *settings = [self.store settingsForOverlay:ov];
                                                                                           settings.semiTransparent = !settings.semiTransparent;
                                                                                           [self.store didUpdatedOverlay:ov];
                                                                                           tableView.editing = NO;
                                                                                       }];
        toggleSemitransAction.backgroundColor = [UIColor blueColor];
        [actions addObject:toggleSemitransAction];
    }

    return actions;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == SECTION_GROUND_OVERLAYS || indexPath.section == SECTION_MARKERS;
}

#pragma mark - helper methods

- (MapOverlay *) mapOverlayOn:(NSIndexPath *) path {
    if (path.section == SECTION_GROUND_OVERLAYS) {
        return [self filterGroundOverlaysOfClass:[GroundOverlay class]][path.row];
    } else if (path.section == SECTION_MARKERS) {
        return [self filterGroundOverlaysOfClass:[MarkerOverlay class]][path.row];
    } else {
        return nil;
    }
}

- (NSIndexPath *) indexPathOfMapOverlay:(MapOverlay *) overlay {
    NSInteger section = -1;
    NSInteger row = [[self filterGroundOverlaysOfClass:overlay.class] indexOfObject:overlay];

    if ([overlay isKindOfClass:[GroundOverlay class]]) {
        section = SECTION_GROUND_OVERLAYS;
    } else {
        section = SECTION_MARKERS;
    }

    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSArray<MapOverlay *> *) filterGroundOverlaysOfClass:(Class) klass {
    NSMutableArray *result = [NSMutableArray new];
    for (MapOverlay *overlay in self.store.allOverlays) {
        if ([overlay isKindOfClass:klass])
            [result addObject:overlay];
    }

    return result;
}

@end
