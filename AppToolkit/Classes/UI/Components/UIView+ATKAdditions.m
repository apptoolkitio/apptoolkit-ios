//
//  UIView+ATKAdditions.m
//  AppToolkit
//
//  Created by Rizwan Sattar on 8/10/15.
//
//

#import "UIView+ATKAdditions.h"

@implementation UIView (ATKAdditions)

- (CGFloat)atk_cornerRadius
{
    if ([self.layer respondsToSelector:@selector(cornerRadius)]) {
        return [self.layer cornerRadius];
    }
    return 0.0;
}

- (void) setAtk_cornerRadius:(CGFloat)atk_cornerRadius
{
    if ([self.layer respondsToSelector:@selector(setCornerRadius:)]) {
        self.layer.cornerRadius = atk_cornerRadius;
    }
}

- (CGFloat)atk_borderWidth
{
    if ([self.layer respondsToSelector:@selector(borderWidth)]) {
        return [self.layer borderWidth];
    }
    return 0.0;
}

- (void)setAtk_borderWidth:(CGFloat)atk_borderWidth
{
    if ([self.layer respondsToSelector:@selector(setBorderWidth:)]) {
        self.layer.borderWidth = atk_borderWidth;
    }
}

- (UIColor *)atk_borderColor
{
    if ([self.layer respondsToSelector:@selector(borderColor)]) {
        CGColorRef borderColorRef = self.layer.borderColor;
        if (borderColorRef != NULL) {
            return [UIColor colorWithCGColor:borderColorRef];
        }
    }
    return nil;
}

- (void)setAtk_borderColor:(UIColor *)atk_borderColor
{
    if ([self.layer respondsToSelector:@selector(setBorderColor:)]) {
        self.layer.borderColor = atk_borderColor.CGColor;
    }
}



@end
