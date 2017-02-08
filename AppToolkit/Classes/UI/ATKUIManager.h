//
//  ATKUIManager.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 1/19/15.
//
//

#import <Foundation/Foundation.h>

#import "AppToolkitShared.h"
#import "ATKBundlesManager.h"
#import "ATKViewController.h"

typedef void (^ATKReleaseNotesCompletionHandler)(BOOL didPresent);
typedef void (^ATKRemoteUILoadHandler)(ATKViewController * _Nullable viewController, NSError * _Nullable error);
typedef void (^ATKRemoteUIDismissalHandler)(ATKViewControllerFlowResult flowResult);
// Used internally, returning additional usage stats
typedef void (^ATKOnboardingUIDismissHandler)(ATKViewControllerFlowResult flowResult,
                                             NSDictionary * _Nullable additionalFlowParameters,
                                             ATKBundleInfo * _Nullable bundleInfo,
                                             NSDate * _Nonnull onboardingStartTime,
                                             NSDate * _Nonnull onboardingEndTime,
                                             NSTimeInterval preOnboardingDuration);
// Used externally, to report overall flow result
typedef void (^ATKOnboardingUICompletionHandler)(ATKViewControllerFlowResult flowResult);
typedef void (^ATKAppRatingPromptCompletionHandler)(BOOL didPresent, ATKViewControllerFlowResult flowResult);

@class ATKUIManager;
@protocol ATKUIManagerDelegate <NSObject>

- (void)uiManagerRequestedToReportUIEvent:(nonnull NSString *)eventName
                             uiBundleInfo:(nullable ATKBundleInfo *)uiBundleInfo
                     additionalParameters:(nullable NSDictionary *)additionalParameters;

@end


@interface ATKUIManager : NSObject

@property (weak, nonatomic, nullable) NSObject <ATKUIManagerDelegate> *delegate;

@property (assign, nonatomic) BOOL debugMode;
@property (assign, nonatomic) BOOL verboseLogging;

- (nonnull instancetype)initWithBundlesManager:(nonnull ATKBundlesManager *)bundlesManager;

#pragma mark - Remote UI Loading
/*!
 @method

 @abstract
 Loads remote UI (generally cached to disk) you have configured at apptoolkit.io to work with this app.

 @discussion
 Given an id, AppToolkit will look for a UI with that id within its remote UI cache, and perhaps retrieve it
 on demand. The view controller returned is a special view controller that is designed to work with the remote
 nibs retrieved from AppToolkit. You can tell AppToolkit to present this view controller using
 -presentRemoteUIViewController:fromViewController:animated:dismissalHandler

 @param remoteUIId A string representing the id of the UI you want to load. This is configured at apptoolkit.io.
 @param completion When the remote UI is available, an instance of the view controller is returned. If an error occurred,
 the error is returned as well. You should ret

 */
- (void)loadRemoteUIWithId:(nonnull NSString *)remoteUIId completion:(nullable ATKRemoteUILoadHandler)completion;

#pragma mark - Presenting UI


/*!
 @method

 @abstract
 Presents loaded remote UI on behalf of the presentingViewController, handling its dismissal.

 @discussion
 Once remote UI is loaded (see -loadRemoteUIWithId:completion:), you should pass it to this method to present it.

 @param viewController The AppToolkit view controller that is generally loaded on demand
 @param presentingViewController The view controller to present the remote UI from.
 @param animated Whether to animate the modal presentation
 @param dismissalHandler When the remote UI has finished its flow, the UI is dismissed, and then this handler
 is called, in case you want to take action after its dismissal.
 */
- (void)presentRemoteUIViewController:(nonnull ATKViewController *)viewController
                   fromViewController:(nonnull UIViewController *)presentingViewController
                             animated:(BOOL)animated
                     dismissalHandler:(nullable ATKRemoteUIDismissalHandler)dismissalHandler;
- (BOOL)remoteUIPresentedForThisAppVersion:(nonnull NSString *)remoteUIId;

#pragma mark - Onboarding UI
- (void)presentOnboardingUIOnWindow:(nullable UIWindow *)window
                maxWaitTimeInterval:(NSTimeInterval)maxWaitTimeInterval
                  completionHandler:(nullable ATKOnboardingUICompletionHandler)completionHandler;

#pragma mark - App Review Card
- (void) presentAppRatingPromptIfNeededFromViewController:(nonnull UIViewController *)presentingViewController
                                               completion:(nullable ATKAppRatingPromptCompletionHandler)completion;

#pragma mark - App Release Notes
- (void) presentAppReleaseNotesFromViewController:(nonnull UIViewController *)viewController
                                       completion:(nullable ATKReleaseNotesCompletionHandler)completion;

@end
