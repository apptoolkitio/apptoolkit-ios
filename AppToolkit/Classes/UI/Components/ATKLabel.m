//
//  ATKLabel.m
//  Pods
//
//  Created by Rizwan Sattar on 2/26/16.
//
//

#import "ATKLabel.h"

@implementation ATKLabel

- (void) layoutSubviews
{
    if (self.atk_updatePreferredMaxLayoutWidthUponLayout) {
        self.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
    }
    [super layoutSubviews];
}

@end
