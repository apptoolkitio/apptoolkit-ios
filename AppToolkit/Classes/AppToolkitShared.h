//
//  AppToolkitShared.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 6/19/15.
//
//

#ifndef AppToolkitShared_h
#define AppToolkitShared_h

#import <UIKit/UIKit.h>
#import "ATKConfig.h"
#import "ATKViewController.h"

#define APPTOOLKIT_VERSION @"2.1.3"

#pragma mark - ATKConfig Convenience Functions

extern BOOL ATKConfigBool(NSString *__nonnull key, BOOL defaultValue);
extern NSInteger ATKConfigInteger(NSString *__nonnull key, NSInteger defaultValue);
extern double ATKConfigDouble(NSString *__nonnull key, double defaultValue);
extern NSString * __nullable ATKConfigString(NSString *__nonnull key, NSString *__nullable defaultValue);
/**
 * A block to ATKConfigReady will get called on the very first
 * update to the configuration (whether or not the configuration is different
 * from the previous configuration). This is an easy place to do some "set once"
 * tasks for your app.
 */
extern void ATKConfigReady(ATKConfigReadyHandler _Nullable readyHandler);
/**
 * A block to ATKConfigRefreshed will get called on the very first
 * network retrieval of the configuration (whether or not the configuration is different
 * from the previous configuration), and all subsequent changes. This is an easy place
 * to do some global property setting for your app.
 */
extern void ATKConfigRefreshed(ATKConfigRefreshHandler _Nullable refreshHandler);

#pragma mark - ATKAppUser Convenience Functions
extern BOOL ATKAppUserIsSuper();

#pragma mark - Remote UI

#endif
