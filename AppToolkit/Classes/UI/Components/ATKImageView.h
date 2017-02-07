//
//  ATKImageView.h
//  AppToolkit
//
//  Created by Rizwan Sattar on 8/28/15.
//
//

#import <UIKit/UIKit.h>

@interface ATKImageView : UIImageView

@property (assign, nonatomic) IBInspectable BOOL atk_templateAlways;
@property (assign, nonatomic) IBInspectable BOOL atk_heightConstrainedToAspectWidth;

@end
