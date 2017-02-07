//
//  AppToolkitTests.m
//  AppToolkitTests
//
//  Created by Rizwan Sattar on 01/12/2015.
//  Copyright (c) 2014 Rizwan Sattar. All rights reserved.
//

#import <AppToolkit/AppToolkit.h>
#import <AppToolkit/ATKAPIClient.h>
#import <AppToolkit/ATKAnalytics.h>

NSString *const APPTOOLKIT_TEST_API_TOKEN = @"zdpYby-IMTyL0hxn1MvnjCT_jNpgI-20CrU4Tg9ATFqt";

@interface AppToolkit (TestingAdditions)

@property (copy, nonatomic) NSString *apiToken;
/** Long-lived, persistent dictionary that is sent up with API requests. */
@property (copy, nonatomic) NSDictionary *sessionParameters;
@property (strong, nonatomic) ATKAPIClient *apiClient;
@property (strong, nonatomic) NSTimer *trackingTimer;
@property (assign, nonatomic) NSTimeInterval trackingInterval;
// Analytics
@property (strong, nonatomic) ATKAnalytics *analytics;
// Config
@property (readwrite, strong, nonatomic, nonnull) ATKConfig *config;
// Bundles
@property (strong, nonatomic) ATKBundlesManager *bundlesManager;

- (nonnull instancetype)initWithToken:(NSString *)apiToken;
- (void)archiveSession;
- (void)retrieveSessionFromArchiveIfAvailable;
- (void)trackProperties:(NSDictionary *)properties completionHandler:(void (^)())completion;

@end

@interface ATKConfig (TestingAdditions)

@property (readwrite, strong, nonatomic, nonnull) NSDictionary *parameters;
- (NSDictionary *)dictionaryWithoutAppToolkitKeys:(nonnull NSDictionary *)dictionary;

@end

@interface ATKAPIClient (TestingAdditions)

@property (strong, nonatomic) NSString *cachedBundleIdentifier; // E.g.: com.yourcompany.appname
@property (strong, nonatomic) NSString *cachedBundleVersion;    // E.g.: 1.2
@property (strong, nonatomic) NSString *cachedBuildNumber;      // E.g.: 14
@property (strong, nonatomic) NSString *cachedOSVersion;        // E.g.: iOS 8.1.3
@property (strong, nonatomic) NSString *cachedHardwareModel;    // E.g.: iPhone 7,1
@property (strong, nonatomic) NSString *cachedLocaleIdentifier; // E.g.: en_US, system's current language + region
@property (strong, nonatomic) NSString *cachedAppLocalization;  // E.g.: en, the localization the app is running as

@end

@interface ATKBundlesManager (TestingAdditions)

- (ATKBundleInfo *)localBundleInfoWithName:(NSString *)name;
- (ATKBundleInfo *)remoteBundleInfoWithName:(NSString *)name;
- (void)retrieveAndCacheAvailableRemoteBundlesWithAssociatedServerTimestamp:(NSDate *)serverTimestamp completion:(void (^)(NSError *error))completion;

@end

SpecBegin(AppToolkitTest)

describe(@"AppToolkit", ^{

    __block AppToolkit *appToolkit = nil;
    beforeAll(^{
        appToolkit = [[AppToolkit alloc] initWithToken:APPTOOLKIT_TEST_API_TOKEN];
    });

    afterAll(^{
        appToolkit = nil;
    });

    
    it(@"stores the API Token passed in", ^{
        expect(appToolkit.apiToken).to.equal(APPTOOLKIT_TEST_API_TOKEN);
    });

    it(@"can restore its session parameters", ^{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:appToolkit.sessionParameters];
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        params[@"test"] = @(timeInterval);
        appToolkit.sessionParameters = params;
        [appToolkit archiveSession];
        [appToolkit retrieveSessionFromArchiveIfAvailable];
        expect(appToolkit.sessionParameters).to.equal(params);
    });

    it(@"can handle multiple track calls, in sequence", ^{
        __block NSString *firstSessionId = nil;
        __block NSString *secondSessionId = nil;

        waitUntil(^(DoneCallback done) {
            appToolkit.sessionParameters = @{};
            [appToolkit trackProperties:nil completionHandler:^{
                // Should give us a new session Id
                firstSessionId = appToolkit.sessionParameters[@"session_id"];
            }];
            [appToolkit trackProperties:nil completionHandler:^{
                // Should give us the same session id
                secondSessionId = appToolkit.sessionParameters[@"session_id"];
                done();
            }];
        });
        expect(firstSessionId).to.equal(secondSessionId);
    });

});

describe(@"ATKConfig", ^{

    __block ATKConfig *config = nil;
    beforeAll(^{
        config = [[ATKConfig alloc] initWithParameters:@{}];
    });

    beforeEach(^{
        config.parameters = @{};
    });

    afterAll(^{
        config = nil;
    });

    it(@"returns BOOL correctly", ^{
        config.parameters = @{@"key" : @(YES)};
        BOOL extracted = [config boolForKey:@"key" defaultValue:NO];
        expect(extracted).to.equal(YES);
    });

    it(@"BOOL returns defaultValue if invalid", ^{
        config.parameters = @{@"key" : @"Not a bool"};
        BOOL extracted = [config boolForKey:@"key" defaultValue:YES];
        expect(extracted).to.equal(YES);
    });

    it(@"returns NSInteger correctly", ^{
        NSInteger originalValue = 15;
        config.parameters = @{@"key" : @(originalValue)};
        NSInteger extracted = [config integerForKey:@"key" defaultValue:-1];
        expect(extracted).to.equal(originalValue);
    });

    it(@"NSInteger returns defaultValue if invalid", ^{
        config.parameters = @{@"key" : @"Not an integer"};
        NSInteger extracted = [config integerForKey:@"key" defaultValue:-1];
        expect(extracted).to.equal(-1);
    });

    it(@"returns double correctly", ^{
        double originalValue = [[NSDate date] timeIntervalSince1970];
        config.parameters = @{@"key" : @(originalValue)};
        double extracted = [config doubleForKey:@"key" defaultValue:0.0];
        expect(extracted).to.equal(originalValue);
    });

    it(@"double returns defaultValue if invalid", ^{
        config.parameters = @{@"key" : @"Not a double"};
        double extracted = [config integerForKey:@"key" defaultValue:0.0];
        expect(extracted).to.equal(0.0);
    });

    it(@"returns NSString* correctly", ^{
        NSString *originalValue = @"Oh look, a string!";
        config.parameters = @{@"key" : originalValue};
        NSString *extracted = [config stringForKey:@"key" defaultValue:@"invalid string"];
        expect(extracted).to.equal(originalValue);
    });

    it(@"NSString* returns defaultValue if invalid", ^{
        config.parameters = @{@"key" : @(34)};
        NSString *extracted = [config stringForKey:@"key" defaultValue:@"invalid string"];
        expect(extracted).to.equal(@"invalid string");
    });

    it(@"strips internal keys", ^{
        NSDictionary *parameters = @{@"io.apptoolkit.currentVersionDuration" : @(0.018598),
                                     @"io.apptoolkit.installDuration" : @(0.018624)};
        NSDictionary *stripped = [config dictionaryWithoutAppToolkitKeys:parameters];
        expect(stripped.count).to.equal(0);
    });
});


describe(@"ATKBundlesManager", ^{


    __block AppToolkit *appToolkit = nil;
    beforeAll(^{
        [ATKBundlesManager deleteBundlesCacheDirectory];

        appToolkit = [[AppToolkit alloc] initWithToken:APPTOOLKIT_TEST_API_TOKEN];
        appToolkit.apiClient.cachedBundleIdentifier = @"io.apptoolkit.AppToolkitSample.ATKBundlesTest";
    });

    afterAll(^{
        appToolkit = nil;
    });

    it(@"does not have local release notes bundle", ^{
        ATKBundleInfo *info = [appToolkit.bundlesManager localBundleInfoWithName:@"WhatsNew"];
        expect(info).to.beNil();
    });

    it(@"can find the release notes bundle for 1.0", ^{
        appToolkit.apiClient.cachedBundleVersion = @"1.0";
        waitUntil(^(DoneCallback done) {
            [appToolkit.bundlesManager retrieveAndCacheAvailableRemoteBundlesWithAssociatedServerTimestamp:nil completion:^(NSError *error) {
                done();
            }];
        });
        ATKBundleInfo *info = [appToolkit.bundlesManager localBundleInfoWithName:@"WhatsNew"];
        expect(info).to.beInstanceOf([ATKBundleInfo class]);
    });

    it(@"up-to-date manifest can return a bundle immediately, if available", ^{
        // Ensure that we save our remote bundles with an actual timestamp that's testable
        NSDate *now = [NSDate date];
        waitUntil(^(DoneCallback done) {
            [appToolkit.bundlesManager retrieveAndCacheAvailableRemoteBundlesWithAssociatedServerTimestamp:now completion:^(NSError *error) {
                done();
            }];
        });
        // Now create a new ATK instance, with a new bundles manager instance
        AppToolkit *newATKInstance = [[AppToolkit alloc] initWithToken:APPTOOLKIT_TEST_API_TOKEN];
        newATKInstance.apiClient.cachedBundleIdentifier = @"io.apptoolkit.AppToolkitSample.ATKBundlesTest";
        newATKInstance.apiClient.cachedBundleVersion = @"1.0";

        // Simulate how the bundlesManager might be told it is up-to-date
        //NSLog(@"Marking bundles manager as 'up-to-date'");
        [newATKInstance.bundlesManager updateServerBundlesUpdatedTimeWithTime:now];

        waitUntil(^(DoneCallback done) {
            //NSLog(@"Waiting 2.0 secs...");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                done();
            });
        });
        __block BOOL loadedBundle = NO;
        waitUntilTimeout(2.0, ^(DoneCallback done) {
            //NSLog(@"loading 'WhatsNew' bundle in uptodate bundles manager...");
            [newATKInstance.bundlesManager loadBundleWithId:@"WhatsNew" completion:^(NSBundle *bundle, NSError *error) {
                //NSLog(@"'WhatsNew' bundle did load in the bundles manager!");
                loadedBundle = (bundle != nil);
                done();
            }];
        });
        expect(loadedBundle).to.beTruthy();
    });

    it(@"can delete expired bundles", ^{
        appToolkit.apiClient.cachedBundleVersion = @"2.0";
        waitUntil(^(DoneCallback done) {
            [appToolkit.bundlesManager retrieveAndCacheAvailableRemoteBundlesWithAssociatedServerTimestamp:nil completion:^(NSError *error) {
                done();
            }];
        });
        ATKBundleInfo *info = [appToolkit.bundlesManager localBundleInfoWithName:@"WhatsNew"];
        expect(info).to.beNil();
    });

});

/*
describe(@"these will fail", ^{

    it(@"can do maths", ^{
        expect(1).to.equal(2);
    });

    it(@"can read", ^{
        expect(@"number").to.equal(@"string");
    });
    
    it(@"will wait and fail", ^AsyncBlock {
        
    });
});

describe(@"these will pass", ^{
    
    it(@"can do maths", ^{
        expect(1).beLessThan(23);
    });
    
    it(@"can read", ^{
        expect(@"team").toNot.contain(@"I");
    });
    
    it(@"will wait and succeed", ^AsyncBlock {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            done();
        });
    });
});
*/

SpecEnd
