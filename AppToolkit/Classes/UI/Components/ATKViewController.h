//
//  ATKViewController.h
//  AppToolkitRemoteUITest
//
//  Created by Rizwan Sattar on 6/15/15.
//  Copyright (c) 2015 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ATKBundleInfo.h"

typedef NS_ENUM(NSInteger, ATKViewControllerFlowResult)
{
    ATKViewControllerFlowResultNotSet,
    ATKViewControllerFlowResultCompleted,
    ATKViewControllerFlowResultCancelled,
    ATKViewControllerFlowResultFailed,
};

extern  NSString * _Nonnull NSStringFromViewControllerFlowResult(ATKViewControllerFlowResult result);

@class ATKViewController;
@protocol ATKViewControllerFlowDelegate <NSObject>

- (void)appToolkitController:(nonnull ATKViewController *)controller
         didFinishWithResult:(ATKViewControllerFlowResult)result
                    userInfo:(nullable NSDictionary *)userInfo;

@end


@interface ATKViewController : UIViewController

@property (weak, nonatomic, nullable) id <ATKViewControllerFlowDelegate> flowDelegate;
@property (readonly, nonatomic) ATKViewControllerFlowResult finishedFlowResult;

@property (strong, nonatomic, nullable) ATKBundleInfo *bundleInfo;

@property (assign, nonatomic) IBInspectable BOOL statusBarShouldHide;
@property (assign, nonatomic) IBInspectable NSInteger statusBarStyleValue;

@property (assign, nonatomic) IBInspectable BOOL portraitOnlyOnNarrowScreens;

@property (strong, nonatomic, nullable) IBInspectable NSString *unwindSegueClassName;
@property (strong, nonatomic, nullable) IBInspectable NSString *presentationStyleName;

@property (assign, nonatomic) IBInspectable CGFloat viewCornerRadius;
@property (assign, nonatomic) IBInspectable BOOL hasMeasureableSize;

// 'cardView' property can be set by a custom IB storyboard, but if it is not set,
// then it will reference self.view (it is set during viewDidLoad)
@property (strong, nonatomic, nullable) IBOutlet UIView *cardView;
@property (assign, nonatomic) IBInspectable BOOL cardPresentationCastsShadow;
@property (assign, nonatomic) CGFloat cardPresentationShadowRadius;
@property (assign, nonatomic) CGFloat cardPresentationShadowAlpha;

#pragma mark - Flow Delegation
- (void) finishFlowWithResult:(ATKViewControllerFlowResult)result
                     userInfo:(nullable NSDictionary *)userInfo;

@end
