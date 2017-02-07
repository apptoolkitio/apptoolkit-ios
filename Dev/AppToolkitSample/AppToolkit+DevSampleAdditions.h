//
//  AppToolkit+DevSampleAdditions.h
//  AppToolkitSample
//
//  Created by Rizwan Sattar on 8/25/15.
//  Copyright (c) 2015 Cluster Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AppToolkit/AppToolkit.h>

@interface AppToolkit (DevSampleAdditions)

@property (copy, nonatomic) NSString *apiToken;
/** Long-lived, persistent dictionary that is sent up with API requests. */
@property (copy, nonatomic) NSDictionary *sessionParameters;
//@property (strong, nonatomic) ATKAPIClient *apiClient;
//@property (strong, nonatomic) NSTimer *trackingTimer;
@property (assign, nonatomic) NSTimeInterval trackingInterval;
//// Analytics
//@property (strong, nonatomic) ATKAnalytics *analytics;
//// Config
//@property (readwrite, strong, nonatomic, nonnull) ATKConfig *config;
//- (nonnull instancetype)initWithToken:(NSString *)apiToken;
//- (void)archiveSession;
//- (void)retrieveSessionFromArchiveIfAvailable;

@end
