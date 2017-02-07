//
//  ATKBundlesManager.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 7/27/15.
//
//

#import <Foundation/Foundation.h>

#import "ATKAPIClient.h"
#import "ATKBundleInfo.h"

extern NSString *const ATKBundlesManagerDidFinishRetrievingBundlesManifest;
extern NSString *const ATKBundlesManagerDidFinishDownloadingRemoteBundles;

typedef void (^ATKRemoteBundleLoadHandler)(NSBundle * bundle, NSError * error);

@class ATKBundlesManager;
@protocol ATKBundlesManagerDelegate <NSObject>

- (void) bundlesManagerRemoteManifestWasRefreshed:(ATKBundlesManager *)manager;

@end

@interface ATKBundlesManager : NSObject

@property (weak, nonatomic) NSObject <ATKBundlesManagerDelegate> *delegate;

@property (assign, nonatomic) BOOL debugMode;
@property (assign, nonatomic) BOOL verboseLogging;

@property (readonly, nonatomic) BOOL hasNewestRemoteBundles;
@property (readonly, nonatomic) BOOL retrievingRemoteBundles;
@property (readonly, nonatomic) BOOL latestRemoteBundlesManifestRetrieved;
@property (readonly, nonatomic) BOOL remoteBundlesDownloaded;

@property (readonly, strong, nonatomic) NSDate *lastManifestRetrievalTime;

- (instancetype) initWithAPIClient:(ATKAPIClient *)apiClient;

- (void) rebuildLocalBundlesMap;
- (void) loadBundleWithId:(NSString *)bundleId completion:(ATKRemoteBundleLoadHandler)completion;
- (ATKBundleInfo *)localBundleInfoWithName:(NSString *)name;
- (ATKBundleInfo *)remoteBundleInfoWithName:(NSString *)name;

+ (NSBundle *)cachedBundleFromInfo:(ATKBundleInfo *)info;
+ (void)deleteBundlesCacheDirectory;

- (void) updateServerBundlesUpdatedTimeWithTime:(NSDate *)bundlesUpdatedTime;
@end
