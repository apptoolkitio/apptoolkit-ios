//
//  AppDelegate.m
//  AppToolkit
//
//  Created by CocoaPods on 01/12/2015.
//  Copyright (c) 2014 Rizwan Sattar. All rights reserved.
//

#import "AppDelegate.h"

#import <AppToolkit/AppToolkit.h>

#define USE_LOCAL_APPTOOLKIT_SERVER 0

static NSString *const APPTOOLKIT_TOKEN = @"YOUR_APPTOOLKIT_TOKEN";

@interface AppDelegate () <UIAlertViewDelegate>

// For token warnings
@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"appToolkitToken" : APPTOOLKIT_TOKEN}];
    [self.window makeKeyAndVisible];
    [self startAppToolkitIfPossible];

    AppToolkit *lk = [AppToolkit sharedInstance];
    [lk presentOnboardingUIOnWindow:self.window completionHandler:^(ATKViewControllerFlowResult flowResult) {
        NSLog(@"Showed onboarding!");
    }];
    return YES;
}

- (NSString *)availableAppToolkitToken
{
    NSString *appToolkitToken = APPTOOLKIT_TOKEN;
    if ([appToolkitToken isEqualToString:@"YOUR_APPTOOLKIT_TOKEN"]) {
        // Otherwise fetch the apptoolkit token from the Settings bundle
        appToolkitToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"appToolkitToken"];
    }
    if (appToolkitToken.length == 0 || [appToolkitToken isEqualToString:@"YOUR_APPTOOLKIT_TOKEN"]) {
        return nil;
    }
    // Could still be nil
    return appToolkitToken;
}

- (BOOL)startAppToolkitIfPossible
{
    NSString *appToolkitToken = [self availableAppToolkitToken];
    if (appToolkitToken == nil || [AppToolkit hasLaunched]) {
        return NO;
    }

    // Valid token, so create AppToolkit instance
#if USE_LOCAL_APPTOOLKIT_SERVER
    [AppToolkit useLocalAppToolkitServer:YES];
#endif
    [AppToolkit launchWithToken:appToolkitToken];
    [AppToolkit sharedInstance].debugMode = YES;
    [AppToolkit sharedInstance].verboseLogging = YES;
    // Use convenience method for setting up the ready-handler
    ATKConfigReady(^{
        NSLog(@"Config is ready");
    });
    // Use the normal method for setting up the refresh handler
    [AppToolkit sharedInstance].config.refreshHandler = ^(NSDictionary *oldParameters, NSDictionary *newParameters) {
        NSLog(@"Config was refreshed!");
    };
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([self availableAppToolkitToken] != nil) {
        // We have a token, so close out any alerts
        if (self.alertController) {
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        } else if (self.alertView) {
            [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
        }
        self.alertController = nil;
        self.alertView = nil;

        if (![AppToolkit hasLaunched]) {
            [self startAppToolkitIfPossible];
        }
    } else {
        if (self.alertController == nil && self.alertView == nil) {
            // We've never shown this alert before

            NSString *title = @"Set AppToolkit Token";
            NSString *msg = @"You must go to Settings and enter "
            "in your AppToolkit token.";
            if (NSClassFromString(@"UIAlertController") != nil) {

                self.alertController = [UIAlertController alertControllerWithTitle:title
                                                                           message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                __weak AppDelegate *_weakSelf = self;
                [self.alertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    _weakSelf.alertController = nil;
                }]];
                [self.alertController addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    _weakSelf.alertController = nil;
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }]];
                [self.window.rootViewController presentViewController:self.alertController
                                                             animated:YES
                                                           completion:nil];

            } else {
                self.alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
                [self.alertView show];
            }
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.alertView = nil;
}

@end
