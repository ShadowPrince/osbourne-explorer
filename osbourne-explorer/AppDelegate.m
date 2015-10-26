//
//  AppDelegate.m
//  osbourne-explorer
//
//  Created by shdwprince on 10/8/15.
//  Copyright © 2015 shdwprince. All rights reserved.
//

#import "AppDelegate.h"
#import "OverlayViewController.h"
#import "MMDrawerController.h"

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

@interface AppDelegate ()

@end@implementation AppDelegate

- (BOOL) application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    [SettingsController sync];
    [GMSServices provideAPIKey:@"AIzaSyDtHMS51p_ihmIOKWLDT8_GOyRtyXpL0cg"];
    //@TODO: comment out
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL) application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL) application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[MapOverlayStore sharedInstance] requestSharedResourcesUnloading];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[MapOverlayStore sharedInstance] requestSharedResourcesLoading];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
