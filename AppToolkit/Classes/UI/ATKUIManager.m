//
//  ATKUIManager.m
//  AppToolkit
//
//  Created by Rizwan Sattar on 1/19/15.
//
//

#import "ATKUIManager.h"

#import "AppToolkitShared.h"
#import "ATKCardPresentationController.h"
#import "ATKLog.h"
#import "ATKOnboardingViewController.h"

@interface ATKUIManager () <ATKViewControllerFlowDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) ATKBundlesManager *bundlesManager;

@property (strong, nonatomic) ATKViewController *remoteUIPresentedController;
@property (weak, nonatomic) UIViewController *remoteUIPresentingController;
@property (copy, nonatomic) ATKRemoteUIDismissalHandler remoteUIControllerDismissalHandler;

@property (strong, nonatomic) NSMutableDictionary *appVersionsForPresentedBundleId;

// Onboarding UI
@property (strong, nonatomic, nullable) UIViewController *postOnboardingRootViewController;
@property (strong, nonatomic, nullable) UIWindow *onboardingWindow;

@end

@implementation ATKUIManager

- (instancetype)initWithBundlesManager:(ATKBundlesManager *)bundlesManager
{
    self = [super init];
    if (self) {
        self.bundlesManager = bundlesManager;
        self.appVersionsForPresentedBundleId = [@{} mutableCopy];
        [self restoreAppVersionsForPresentedBundleIdFromArchive];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Remote Native UI Loading

- (void)loadRemoteUIWithId:(NSString *)remoteUIId completion:(ATKRemoteUILoadHandler)completion
{
    [self.bundlesManager loadBundleWithId:remoteUIId completion:^(NSBundle *bundle, NSError *error) {

        if (bundle == nil || (error != nil || error.code == 404)) {
            error = [self uiNotFoundError];
            if (self.debugMode) {
                ATKLogError(@"The requested UI was not found in your AppToolkit account. Things to check:\n"
                           "— You have pressed \"Publish\" on the UI on the web editor.\n"
                           "— Your app's bundle identifier matches with the UI on the web dashboard.\n"
                           "— Your SDK token matches your account.");
                if (self.verboseLogging) {
                    ATKLogError(@"Error: %@", error);
                }
            }
            if (completion) {
                completion(nil, error);
            }
            return;
        }

        NSError *preparationError = nil;
        ATKViewController *viewController = [self preparedViewControllerWithId:remoteUIId fromBundle:bundle error:&preparationError];

        if (completion) {
            completion(viewController, preparationError);
        }
    }];
}


- (nullable ATKViewController *)preparedViewControllerWithId:(nonnull NSString *)remoteUIId fromBundle:(nonnull NSBundle *)bundle error:(NSError **)error
{

    UIStoryboard *storyboard = nil;
    if ([bundle URLForResource:remoteUIId withExtension:@"storyboardc"] != nil) {
        storyboard = [UIStoryboard storyboardWithName:remoteUIId bundle:bundle];
    }
    if (storyboard == nil) {
        // Hmm there isn't a storyboard that matches the name of the bundle/remote-id, so try finding any storyboard for now :okay:
        NSArray *storyboardUrls = [bundle URLsForResourcesWithExtension:@"storyboardc" subdirectory:nil];
        if (storyboardUrls.count > 0) {
            NSString *storyboardName = ((NSURL *)storyboardUrls[0]).lastPathComponent.stringByDeletingPathExtension;
            storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
        }
    }
    if (storyboard == nil) {
        *error = [self uiNotFoundError];
        return nil;
    }

    // At this point we have a valid storyboard, so try to load a vc inside
    ATKViewController *viewController = nil;
    @try {
        viewController = [storyboard instantiateInitialViewController];
    }
    @catch (NSException *exception) {
        // In production, there seems to be an intermittent NSInternalConsistencyException
        // which causes a crash. A way to reproduce this is to take the .nib file *inside*
        // a .storyboardc file and either delete or rename it. (i.e. "WhatsNew.nib.fake")
        // It is unclear why this would be happening. Perhaps an unzipping error, or disk
        // corruption?
        ATKLogError(@"Encountered error loading ATK storyboard:\n%@", exception);
        NSError *nibLoadError = [NSError errorWithDomain:@"ATKUIManagerError"
                                                    code:500
                                                userInfo:@{@"underlyingException" : exception}];
        *error = nibLoadError;
        return nil;
    }
    @finally {
        // Code that gets executed whether or not an exception is thrown
    }
    // Set the related bundleinfo into the initialviewcontroller, useful later (for tracking)
    viewController.bundleInfo = [self.bundlesManager localBundleInfoWithName:remoteUIId];

    BOOL isCardStyleLayout = [viewController.presentationStyleName isEqualToString:@"card"];
    if (isCardStyleLayout) {
        if ([UIPresentationController class]) {
            viewController.modalPresentationStyle = UIModalPresentationCustom;
            viewController.transitioningDelegate = self;
        } else {
            // iOS 7
            // Make it a "form sheet" so on iPads it won't be full screen
            // On iOS 7 iPhones, this gets ignored and is still a full-screen presentation
            viewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    if (viewController.transitioningDelegate != self) {
        // On iOS 7, we don't have a presentation controller to control our corner radius, so just
        // ensure that our corner radius is 0 (which is the default).
        // Since our .view hasn't loaded yet, we can't set the cornerRadius directly. Instead,
        // we'll use a custom property in our ATKViewController to set a corner radius which *IT*
        // will set upon its -viewDidLoad:
        viewController.viewCornerRadius = 0.0;
    }
    return viewController;
}


- (NSError *)uiNotFoundError
{
    return [[NSError alloc] initWithDomain:@"ATKUIError"
                                      code:404
                                  userInfo:@{@"message" : @"UI with that name does not exist in your AppToolkit account"}];
}


#pragma mark - UIViewControllerTransitioningDelegate


- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    if ([presented isKindOfClass:[ATKViewController class]]) {
        if ([((ATKViewController *)presented).presentationStyleName isEqualToString:@"card"]) {
            return [[ATKCardPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
        }
    }
    return nil;
}


#pragma mark - Presenting Remote UI

- (void)presentRemoteUIViewController:(ATKViewController *)viewController fromViewController:(UIViewController *)presentingViewController animated:(BOOL)animated dismissalHandler:(ATKRemoteUIDismissalHandler)dismissalHandler
{
    if (self.remoteUIPresentedController != nil) {
        // TODO(Riz): Auto-dismiss this view controller?
        [self dismissRemoteUIViewController:self.remoteUIPresentedController animated:NO withFlowResult:ATKViewControllerFlowResultCancelled userInfo:nil];
    }
    if ([viewController isKindOfClass:[ATKViewController class]]) {
        ((ATKViewController *)viewController).flowDelegate = self;
    } else {
        ATKLogWarning(@"Main remote UI view controller is not of type ATKViewController. It is a %@",
                     NSStringFromClass([viewController class]));
    }
    self.remoteUIPresentedController = viewController;
    self.remoteUIPresentingController = presentingViewController;
    self.remoteUIControllerDismissalHandler = ^(ATKViewControllerFlowResult flowResult) {
        if (dismissalHandler) {
            dismissalHandler(flowResult);
        }
    };
    [self.remoteUIPresentingController presentViewController:self.remoteUIPresentedController animated:animated completion:nil];
    if (viewController.bundleInfo.name != nil) {
        [self markPresentationOfRemoteUI:viewController.bundleInfo.name];
    }
}


- (void)dismissRemoteUIViewController:(ATKViewController *)controller animated:(BOOL)animated withFlowResult:(ATKViewControllerFlowResult)flowResult userInfo:(NSDictionary *)userInfo
{
    if (self.remoteUIPresentedController == controller) {
        controller.flowDelegate = nil;

        UIViewController *presentingController = self.remoteUIPresentingController;

        self.remoteUIPresentingController = nil;
        self.remoteUIPresentedController = nil;
        ATKRemoteUIDismissalHandler handler = self.remoteUIControllerDismissalHandler;
        self.remoteUIControllerDismissalHandler = nil;
        [presentingController dismissViewControllerAnimated:animated completion:^{

            if (handler != nil) {
                handler(flowResult);
            }
        }];
    } else {
        ATKLogWarning(@"Could not dismiss %@ as it doesn't match the current presented controller (%@).",
                     controller.bundleInfo.name,
                     self.remoteUIPresentedController.bundleInfo.name);
    }
}


#pragma mark - Onboarding UI


- (void)presentOnboardingUIOnWindow:(UIWindow *)window
                maxWaitTimeInterval:(NSTimeInterval)maxWaitTimeInterval
                  completionHandler:(ATKOnboardingUICompletionHandler)completionHandler;
{
    if (window == nil) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    if (window == nil) {
        ATKLogError(@"Cannot display onboarding UI. Window is not available");
        return;
    }
    self.onboardingWindow = window;
    ATKOnboardingViewController *onboarding = [[ATKOnboardingViewController alloc] init];
    if (maxWaitTimeInterval > 0.0) {
        onboarding.maxWaitTimeInterval = maxWaitTimeInterval;
    }
    self.postOnboardingRootViewController = window.rootViewController;

    // Present it without animation, just swap out root view controller
    self.onboardingWindow.rootViewController = onboarding;

    __weak ATKUIManager *weakSelf = self;
    onboarding.dismissalHandler = ^(ATKViewControllerFlowResult flowResult, NSDictionary *additionalFlowParameters, ATKBundleInfo *bundleInfo, NSDate *onboardingStartTime, NSDate *onboardingEndTime, NSTimeInterval preOnboardingDuration) {

        [weakSelf transitionToRootViewController:weakSelf.postOnboardingRootViewController inWindow:weakSelf.onboardingWindow animation:ATKRootViewControllerAnimationModalDismiss completion:^{

            // Onboarding is done! First record the UI event
            if (bundleInfo != nil) {
                NSMutableDictionary *resultInfo = [NSMutableDictionary dictionary];
                if (additionalFlowParameters) {
                    [resultInfo addEntriesFromDictionary:additionalFlowParameters];
                }
                [resultInfo addEntriesFromDictionary:@{@"flow_result" : NSStringFromViewControllerFlowResult(flowResult),
                                                       @"start_time": @(onboardingStartTime.timeIntervalSince1970),
                                                       @"end_time": @(onboardingEndTime.timeIntervalSince1970),
                                                       @"load_duration": @(preOnboardingDuration)
                                                       }];
                [weakSelf.delegate uiManagerRequestedToReportUIEvent:@"ui-shown"
                                                        uiBundleInfo:bundleInfo
                                                additionalParameters:resultInfo];
            }


            // Then call the completion
            if (completionHandler) {
                completionHandler(flowResult);
            }

            // Cleanup
            weakSelf.onboardingWindow = nil;
            weakSelf.postOnboardingRootViewController = nil;

        }];

    };
    [self loadRemoteUIWithId:@"Onboarding" completion:^(ATKViewController *viewController, NSError *error) {
        if (viewController == nil) {
            ATKLogWarning(@"Unable to load remote onboarding UI, cancelling");
            [onboarding finishOnboardingWithResult:ATKViewControllerFlowResultFailed];
            return;
        }
        [onboarding setActualOnboardingUI:viewController];

        [weakSelf.delegate uiManagerRequestedToReportUIEvent:@"ui-showing"
                                                uiBundleInfo:viewController.bundleInfo
                                        additionalParameters:nil];
    }];
}

typedef NS_ENUM(NSInteger, ATKRootViewControllerAnimation) {
    ATKRootViewControllerAnimationNone,
    ATKRootViewControllerAnimationModalDismiss,
    ATKRootViewControllerAnimationModalPresentation,
};

- (void)transitionToRootViewController:(UIViewController *)toViewController
                              inWindow:(UIWindow *)window
                             animation:(ATKRootViewControllerAnimation)animation
                            completion:(void (^)())completion
{
    void (^doneTransitioning)() = ^{
        if (completion) {
            completion();
        }
    };

    UIViewController *fromViewController = window.rootViewController;

    if (animation == ATKRootViewControllerAnimationNone) {
        window.rootViewController = toViewController;
        doneTransitioning();
    } else if (animation == ATKRootViewControllerAnimationModalDismiss) {

        CGRect endFrame = window.bounds;
        endFrame.origin.y += CGRectGetHeight(endFrame);

        window.rootViewController = toViewController;
        [window insertSubview:fromViewController.view aboveSubview:window.rootViewController.view];

        NSTimeInterval duration = 0.35;
        [UIView transitionWithView:window duration:duration options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            fromViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [fromViewController.view removeFromSuperview];
            doneTransitioning();
        }];

    } else if (animation== ATKRootViewControllerAnimationModalPresentation) {

        window.rootViewController = toViewController;
        [window insertSubview:fromViewController.view belowSubview:window.rootViewController.view];

        // Move rootVC off bounds to "animate" it in
        CGRect startFrame = window.bounds;
        startFrame.origin.y += CGRectGetHeight(startFrame);
        toViewController.view.frame = startFrame;

        NSTimeInterval duration = 0.35;
        [UIView transitionWithView:window duration:duration options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            toViewController.view.frame = window.bounds;
        } completion:^(BOOL finished) {
            [fromViewController.view removeFromSuperview];
            doneTransitioning();
        }];

    }
}


#pragma mark - App Rating Prompt
- (void) presentAppRatingPromptIfNeededFromViewController:(nonnull UIViewController *)presentingViewController
                                               completion:(nullable ATKAppRatingPromptCompletionHandler)completion
{
    [self showUIWithName:@"AppReviewCard" fromViewController:presentingViewController completion:^(ATKViewControllerFlowResult flowResult, NSError *error) {
        if (error) {
            if (error.code == 404) {
                ATKLog(@"AppReviewCard was not found for this app bundle (%@). "
                      "You may have not published a review card yet.", [ATKAPIClient appBundleIdentifier]);
            } else {
                ATKLogError(@"AppReviewCard presentation failed due to error: %@", error);
            }
        }
        if (completion) {
            BOOL didPresent = flowResult == ATKViewControllerFlowResultCompleted || flowResult == ATKViewControllerFlowResultCancelled;
            completion(didPresent, flowResult);
        }
    }];
}


#pragma mark - App Release Notes
- (void) presentAppReleaseNotesFromViewController:(nonnull UIViewController *)viewController
                                       completion:(nullable ATKReleaseNotesCompletionHandler)completion
{
    [self showUIWithName:@"WhatsNew" fromViewController:viewController completion:^(ATKViewControllerFlowResult flowResult, NSError *error) {

        if (error) {
            if (error.code == 404) {
                ATKLog(@"App Release Notes were not found for this app bundle (%@) version %@ (build %@). "
                      "You may have not published any release notes for this bundle ID, version and build yet.", [ATKAPIClient appBundleIdentifier], [ATKAPIClient appBundleVersion], [ATKAPIClient appBuildNumber]);
            } else {
                ATKLogError(@"App Release Notes presentation failed due to error: %@", error);
            }
        }
        if (completion) {
            BOOL didPresent = flowResult == ATKViewControllerFlowResultCompleted || flowResult == ATKViewControllerFlowResultCancelled;
            completion(didPresent);
        }
    }];
}

#pragma mark -

- (void)showUIWithName:(NSString *)uiName fromViewController:(UIViewController *)presentingViewController completion:(void (^)(ATKViewControllerFlowResult flowResult, NSError *error))completion
{
    __weak ATKUIManager *weakSelf = self;
    [self loadRemoteUIWithId:uiName completion:^(ATKViewController *viewController, NSError *error) {
        if (viewController) {
            // Notify AppToolkit that this view controller is being displayed
            [weakSelf.delegate uiManagerRequestedToReportUIEvent:@"ui-showing"
                                                uiBundleInfo:viewController.bundleInfo
                                        additionalParameters:nil];

            [weakSelf presentRemoteUIViewController:viewController fromViewController:presentingViewController animated:YES dismissalHandler:^(ATKViewControllerFlowResult flowResult) {

                // report that the UI was shown
                if (viewController.bundleInfo != nil) {
                    // Notify AppToolkit that this view controller has been displayed
                    NSString *flowResultString = NSStringFromViewControllerFlowResult(flowResult);
                    [weakSelf.delegate uiManagerRequestedToReportUIEvent:@"ui-shown"
                                                            uiBundleInfo:viewController.bundleInfo
                                                    additionalParameters:@{@"flow_result" : flowResultString}];
                }

                if (completion) {
                    completion(flowResult, nil);
                }
            }];
        } else {
            if (completion) {
                completion(ATKViewControllerFlowResultFailed, error);
            }
        }
    }];
}


#pragma mark - ATKViewControllerFlowDelegate


- (void)appToolkitController:(nonnull ATKViewController *)controller didFinishWithResult:(ATKViewControllerFlowResult)result userInfo:(nullable NSDictionary *)userInfo
{
    [self dismissRemoteUIViewController:controller animated:YES withFlowResult:result userInfo:userInfo];
}


#pragma mark - Presentation Helpers

- (UIViewController *)currentPresentedViewController
{
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    return controller;
}

- (UIView *)currentTopWindowView
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (keyWindow) {
        // Thanks to Mixpanel here.
        for (UIView *subview in keyWindow.subviews) {
            if (!subview.hidden && subview.alpha > 0 && CGRectGetWidth(subview.frame) > 0 && CGRectGetHeight(subview.frame) > 0) {
                // First visible view that has some dimensions
                return subview;
            }
        }
    }
    return nil;
}

+ (BOOL)isPad
{
    static BOOL _isPad = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _isPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    });
    return _isPad;
}

#pragma mark - Locally recording which UI's have been shown (by bundle version)

- (void) restoreAppVersionsForPresentedBundleIdFromArchive
{
    NSDictionary *restored = [NSKeyedUnarchiver unarchiveObjectWithFile:[self appVersionsForPresentedBundleIdArchiveFilePath]];
    if (restored != nil) {
        [self.appVersionsForPresentedBundleId removeAllObjects];
        [self.appVersionsForPresentedBundleId addEntriesFromDictionary:restored];
    }
}


- (void) archiveAppVersionsForPresentedBundleId
{
    NSString *archiveFilePath = [self appVersionsForPresentedBundleIdArchiveFilePath];
    NSString *archiveParentDirectory = [archiveFilePath stringByDeletingLastPathComponent];
    NSError *archiveParentDirError = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:archiveParentDirectory withIntermediateDirectories:YES attributes:nil error:&archiveParentDirError];
    if (archiveParentDirError != nil) {
        ATKLogWarning(@"Error trying to create UI prefs archive folder: %@", archiveParentDirError);
    }
    BOOL saved = [NSKeyedArchiver archiveRootObject:self.appVersionsForPresentedBundleId
                                             toFile:archiveFilePath];
    if (!saved) {
        ATKLogWarning(@"Could not save app versions for presented UI's");
    }
}


- (NSString *)appVersionsForPresentedBundleIdArchiveFilePath
{
    // Library/Application Support/apptoolkit/ui/appVersionsForPresentedBundleId.plist
    NSString *appSupportDir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).lastObject;
    NSString *appToolkitDir = [appSupportDir stringByAppendingPathComponent:@"apptoolkit"];
    NSString *ui = [appToolkitDir stringByAppendingPathComponent:@"ui"];
    NSString *filename = [NSString stringWithFormat:@"appVersionsForPresentedBundleId.plist"];
    return [ui stringByAppendingPathComponent:filename];
}


- (NSString *)currentAppVersionAndBuild
{
    NSDictionary *bundleDict = [[NSBundle mainBundle] infoDictionary];
    // Example: 1.5.2
    NSString *version = bundleDict[@"CFBundleShortVersionString"];
    if (!version || ![version isKindOfClass:[NSString class]]) {
        version = @"(unknown)";
    }
    // Example: 10
    NSString *build = bundleDict[@"CFBundleVersion"];
    if (!build || ![build isKindOfClass:[NSString class]]) {
        build = @"(unknown)";
    }
    // Example: 1.5.2-10
    return [NSString stringWithFormat:@"%@-%@", version, build];
}


- (void)markPresentationOfRemoteUI:(NSString *)remoteUIId
{
    NSSet *presentedInVersions = self.appVersionsForPresentedBundleId[remoteUIId];
    NSString *currentVersionAndBuild = [self currentAppVersionAndBuild];
    if (![presentedInVersions member:currentVersionAndBuild]) {
        if (presentedInVersions == nil) {
            presentedInVersions = [NSSet setWithObject:currentVersionAndBuild];
        } else {
            presentedInVersions = [presentedInVersions setByAddingObject:currentVersionAndBuild];
        }
        self.appVersionsForPresentedBundleId[remoteUIId] = presentedInVersions;
        [self archiveAppVersionsForPresentedBundleId];
    }
}


- (BOOL)remoteUIPresentedForThisAppVersion:(NSString *)remoteUIId
{
    NSSet *presentedInVersions = self.appVersionsForPresentedBundleId[remoteUIId];
    NSString *currentVersionAndBuild = [self currentAppVersionAndBuild];
    BOOL hasPresentedInThisVersion = [presentedInVersions member:currentVersionAndBuild] != nil;
    return hasPresentedInThisVersion;
}

@end
