//
//  ATKAnalytics.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 8/13/15.
//
//

#import <UIKit/UIKit.h>

#import "ATKAPIClient.h"
#import "ATKAppUser.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ATKAppUserUpdatedNotificationName;
extern NSString *const ATKPreviousAppUserKey;
extern NSString *const ATKCurrentAppUserKey;

@interface ATKAnalytics : NSObject

@property (assign, nonatomic) BOOL debugMode;
@property (assign, nonatomic) BOOL verboseLogging;

@property (readonly, nonatomic) BOOL shouldReportScreens;
@property (readonly, nonatomic) BOOL shouldReportTaps;

@property (readonly, strong, nonatomic, nullable) ATKAppUser *user;

- (instancetype)initWithAPIClient:(ATKAPIClient *)apiClient;

- (NSDictionary *)commitTrackableProperties;

- (void) updateReportingScreens:(BOOL)shouldReport;
- (void) updateReportingTaps:(BOOL)shouldReport;

- (void) createListeners;
- (void) destroyListeners;

#pragma mark - Current User Data

- (void) updateUserFromDictionary:(NSDictionary *)dictionary reportUpdate:(BOOL)reportUpdate;

@end

NS_ASSUME_NONNULL_END
