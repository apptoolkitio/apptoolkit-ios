//
//  ATKOnboardingViewController.h
//  Pods
//
//  Created by Rizwan Sattar on 1/25/16.
//
//

#import <UIKit/UIKit.h>

#import "ATKViewController.h"
#import "ATKUIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATKOnboardingViewController : ATKViewController

@property (assign, nonatomic) NSTimeInterval maxWaitTimeInterval;
@property (copy, nonatomic, nullable) ATKOnboardingUIDismissHandler dismissalHandler;

- (void) setActualOnboardingUI:(UIViewController *)actualOnboardingUI;
- (void) finishOnboardingWithResult:(ATKViewControllerFlowResult)result;

@end

NS_ASSUME_NONNULL_END
