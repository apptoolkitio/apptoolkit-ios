//
//  UIView+ATKAdditions.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 8/10/15.
//
//

#import <UIKit/UIKit.h>

@interface UIView (ATKAdditions)

@property (assign, nonatomic) IBInspectable CGFloat atk_cornerRadius;
@property (assign, nonatomic) IBInspectable CGFloat atk_borderWidth;
@property (strong, nonatomic, nullable) IBInspectable UIColor *atk_borderColor;

@end
