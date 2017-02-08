//
//  UIView+ATKAdditions.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 8/10/15.
//
//

#import <UIKit/UIKit.h>

@interface UIView (ATKAdditions)

@property (assign, nonatomic) CGFloat atk_cornerRadius;
@property (assign, nonatomic) CGFloat atk_borderWidth;
@property (strong, nonatomic, nullable) UIColor *atk_borderColor;

@end
