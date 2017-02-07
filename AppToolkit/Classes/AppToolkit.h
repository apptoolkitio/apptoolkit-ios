//
//  AppToolkit.h
//  AppToolkit
//
//  Created by Cluster Labs, Inc. on 1/13/15.
//
//

#import <Foundation/Foundation.h>

#import "AppToolkitShared.h"
#import "ATKAppUser.h"
#import "ATKConfig.h"
#import "ATKUIManager.h"

//! Project version number for AppToolkit.
FOUNDATION_EXPORT double AppToolkitVersionNumber;

//! Project version string for AppToolkit.
FOUNDATION_EXPORT const unsigned char AppToolkitVersionString[];

typedef void (^ATKUIManifestRefreshHandler)();

@interface AppToolkit : NSObject

/*!
 @method

 @abstract
 Initializes a singleton instance of AppToolkit and returns it.

 @discussion
 This is the starting point a AppToolkit session. Supply the apiToken for your
 account.

 @param apiToken        your project token

 */
+ (nonnull instancetype)launchWithToken:(nonnull NSString *)apiToken;


/*!
 @method
 
 @abstract
 Returns the shared singleton instance that was previously set up by 
 `+launchWithToken`.
 
 @discussion
 Calling this before calling `+launchWithToken:` will return nil.
 */
+ (nonnull instancetype)sharedInstance;

/*!
 @method

 @abstract
 Returns YES if AppToolkit has been launched with `+launchWithToken`.

 @discussion
 This is useful in case you need to conditionally start AppToolkit
 and need to verify whether it's already started or not.
 */
+ (BOOL)hasLaunched;


/**
 *  Unavailable. Use `+sharedInstance` to retrieve the shared AppToolkit instance.
 */
- (nullable id)init __attribute__((unavailable("Use +launchWithToken: to initialize AppToolkit, and +sharedInstance to retrieve the shared AppToolkit instance.")));

/**
 * User-configurable parameters that you may have set in AppToolkit's Cloud Config tool. See https://apptoolkit.io/config
 */
@property (readonly, strong, nonatomic, nonnull) ATKConfig *config;


/**
 * According to AppToolkit, what information is availabe for the current app user. See https://apptoolkit.io/users
 */
@property (readonly, nonatomic, nullable) ATKAppUser *currentUser;

/**
 * If you have told AppToolkit about this app in the App Store, then this will contains
 * your app's iTunes Store ID.
 */
@property (readonly, nonatomic, nullable) NSString *appiTunesStoreId;

/**
 * Set this handler if you'd like to see when AppToolkit is updated with what remote UI
 * (e.g. App Release Notes) is available for your app (based on version, build, etc.). It will
 * be called whenever the ui manifest is refreshed (at least once a session, and possibly more,
 * if you are editing and publishing UI on AppToolkit's service.
 */
@property (copy, nonatomic, nullable) ATKUIManifestRefreshHandler uiManifestRefreshHandler;

/**
 * This sets the maximum time that AppToolkit should wait while attempting to load your onboarding UI.
 * Default is 15 seconds.
 */
@property (assign, nonatomic) NSTimeInterval maxOnboardingWaitTimeInterval;

/**
 * Returns YES if internal config (based on Cloud Config) says user should be asked for a review.
 * Default is NO. This is generally based on whether the user has seen the review card already, 
 * and whether they are a super user. 
 * Note that config should be ready before checking this property.
 * @see ATKConfigReady
 */
@property (readonly, nonatomic) BOOL shouldAskUserToRateApp;

/**
 * If true, ATKAppUserIsSuper() will always return true, ignoring the value from the server.
 * @discussion This only works when debugging (i.e. when DEBUG = 1)
 */
@property (assign, nonatomic) BOOL debugAppUserIsAlwaysSuper;

/**
 * If true, shouldAskUserToRateApp will always be true, ignoring the value from the server.
 * If asked to show a review card, AppToolkit will ignore any history with that user and
 * always present the review card, provided you have published one for this app version.
 * @discussion This only works when debugging (i.e. when DEBUG = 1)
 */
@property (assign, nonatomic) BOOL debugAlwaysShowAppRatingPrompt;

/** 
 * Useful to see log statements from AppToolkit in your console. Only useful when DEBUG macro = 1
 */
@property (assign, nonatomic) BOOL debugMode;

/**
 * If you want to see verbose log statements. Only useful when DEBUG macro = 1
 */
@property (assign, nonatomic) BOOL verboseLogging;

/**
 * The version of the AppToolkit library
 */
@property (readonly, nonatomic, nonnull) NSString *version;

/**
 * Always present App Update Notes, for testing. (Only valid for debug builds).
 * @discussion Note that your AppToolkit account should have Update Notes configured
 * for this version of your app, or nothing will be shown.
 */
@property (assign, nonatomic) BOOL debugAlwaysPresentAppReleaseNotes;


/*!
 @method

 @abstract
 Sets optional data identifying the user that is currently using your app.

 @discussion
 This is optional, and helps identify a particular user when viewing AppToolkit data.
 You should make sure that sending user data to AppToolkit is acceptable per your
 application's Terms of Use and Privacy Policy.

 @param userIdentifier An arbitrary string, like a database index or hash, that ties an user to your system.
 @param email The user's email address, if your system supports it
 @param name The user's name or username/screenname, if your system supports it.

 */
- (void) setUserIdentifier:(nullable NSString *)userIdentifier email:(nullable NSString *)userEmail name:(nullable NSString *)userName;


#pragma mark - Release Notes

/*!
 @method
 
 @abstract
 Used to check if App Release Notes are available for this app, based on app version, build, and
 publish status on AppToolkit's service. This is useful if you'd like to display a button to show
 App Release Notes on demand. That button can be potentially disabled (or hidden) depending on the
 result.
 
 @return YES if App Release Notes are available (not necessarily downloaded, though), or NO if none
 are available for this app, based on version and build.
 */
- (BOOL) appReleaseNotesAvailable;

/*!
 @method
 
 @abstract
 Presents App Release Notes, as configured on the AppToolkit server on the supplied view controller.
 
 @discussion
 This method should be used in a "fire and forget" style, in that it should be placed at a point in your
 code where it would be appropriate to present release notes to the user. Often it would be used within
 a -viewDidAppear: method (but perhaps not in a place where the user is logged out). Based on several
 factors to determine whether to display release notes:

 – Are there App Release Notes for this version of the app?

 – Have we shown those App Release Notes before, on this device?

 – Are App Release Notes enabled globally for your app by AppToolkit?
 
 @param viewController The view controller from which you wish to present the App Release Notes view controller.
 @param completion (Optional) A completion handler which is called when App Release Notes is dismissed.
 */
- (void) presentAppReleaseNotesIfNeededFromViewController:(nonnull UIViewController *)viewController
                                               completion:(nullable ATKReleaseNotesCompletionHandler)completion;
/*!
 @method

 @abstract
 Presents App Release Notes, as configured on the AppToolkit server on the supplied view controller, ignoring whether it
 has been shown before.

 @discussion
 This method should be used to display App Release Notes if displaying App Release Notes from a user 
 interaction. It will ignore whether or not this version has been shown before, and display them
 as long as they are available for this version of your app.

 @param viewController The view controller from which you wish to present the App Release Notes view controller.
 @param completion (Optional) A completion handler which is called when App Release Notes is dismissed.
 */
- (void) forcePresentationOfAppReleaseNotesFromViewController:(nonnull UIViewController *)viewController
                                                   completion:(nullable ATKReleaseNotesCompletionHandler)completion;

#pragma mark - Onboarding UI
/*!
 @method

 @abstract
 Presents Onboarding UI, as configured on the AppToolkit server on the supplied window.

 @discussion
 When presenting onboarding UI, AppToolkit stores a reference to the existing rootViewController, and replaces
 it with the onboarding view controller. When the onboarding flow is finished, AppToolkit performs a transition
 animation and replaces the onboarding view controller with the original rootViewController.
 
 Before calling this method, ensure that your window has been set with the intended rootViewController.
 
 While the actual onboarding resources may be retrieving from AppToolkit remotely, AppToolkit will display a 
 temporary view, which replicates your application's launch storyboard or xib. If AppToolkit is unable to retrieve
 the actual onboarding UI within a certain amount of time (default 15 seconds), it will finish the process with
 a flowResult of ATKViewControllerFlowResultFailed.

 @param window The UIWindow upon which to present onboarding. Normally this is just your AppDelegate's window
 property
 @param completionHandler (Optional) A completion handler which is called when onboarding is complete. It contains
 a flowResult enumeration, indicating how the user completed the onboarding (or if there was an error).
 
 @see maxOnboardingWaitTimeInterval
 */
- (void)presentOnboardingUIOnWindow:(nonnull UIWindow *)window
                  completionHandler:(nullable ATKOnboardingUICompletionHandler)completionHandler;


#pragma mark - App Rating Prompt
/*!
 @method
 @warning In Private Beta Testing
 */
- (void) presentAppRatingPromptIfNeededFromViewController:(nonnull UIViewController *)viewController
                                               completion:(nullable ATKAppRatingPromptCompletionHandler)completion;


#pragma mark - Debugging (for AppToolkit developers :D)

/*!
 @method

 @abstract
 For AppToolkit internal development. It lets us tell AppToolkit to talk to our own local computer to make
 it easier to iterate while working on new features, debugging, etc.

 @discussion
 Set to YES if you want the AppToolkit instance to be talking to your local computer. Be sure you have
 the local AppToolkit server running. Also ensure that you are using a local API token, and not your
 production token, as it won't be recognized by the local AppToolkit server.
 
 This can only be set BEFORE you have called launchWithToken: or sharedInstance.

 @param useLocalAppToolkitServer Set to YES if you want the AppToolkit instance to be talking to your local computer.

 */
+ (void)useLocalAppToolkitServer:(BOOL)useLocalAppToolkitServer;

@end // End AppToolkit class declaration


#pragma mark - AppToolkit UI Convenience Functions
/**
 * A block to ATKUIManifestReady will get called on the very first
 * network retrieval of the manifest containing which downloadable components
 * are available this app, based on app version + build, etc. This is a good
 * place to check whether presentable UI (like App Release Notes) is available.
 */
extern void ATKUIManifestRefreshed(ATKUIManifestRefreshHandler _Nullable refreshHandler);
