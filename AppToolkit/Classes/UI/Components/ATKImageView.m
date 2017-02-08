//
//  ATKImageView.m
//  AppToolkit
//
//  Created by Rizwan Sattar on 8/28/15.
//
//

#import "ATKImageView.h"

@interface ATKImageView ()

@property (strong, nonatomic, nullable) NSLayoutConstraint *aspectRatioHeightConstraint;

@end

@implementation ATKImageView

//- (instancetype)initWithImage:(UIImage *)image;
//- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage NS_AVAILABLE_IOS(3_0);

- (void) setAtk_templateAlways:(BOOL)atk_templateAlways
{
    if (_atk_templateAlways != atk_templateAlways) {
        _atk_templateAlways = atk_templateAlways;
        // Image
        self.image = [self updatedRenderingModeImageFromImage:self.image];
        // Highlighted Image
        self.highlightedImage = [self updatedRenderingModeImageFromImage:self.highlightedImage];
    }
}

- (UIImage *) updatedRenderingModeImageFromImage:(UIImage *)image
{
    if (image != nil) {
        if (_atk_templateAlways && image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
            return [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else if(!_atk_templateAlways && image.renderingMode == UIImageRenderingModeAlwaysTemplate) {
            // NOTE: The image previously may have been UIImagerenderingModeAlwaysImage :(
            // TODO(Riz): Maybe store the previous renderingMode of the image somewhere, and restore it to that
            return [self.image imageWithRenderingMode:UIImageRenderingModeAutomatic];
        }
    }
    return image;
}

- (void) setImage:(UIImage *)image
{
    [super setImage:[self updatedRenderingModeImageFromImage:image]];

    if (self.atk_heightConstrainedToAspectWidth && self.image) {
        CGFloat imageAspectRatio = self.image.size.height / self.image.size.width;
        // If we haven't constrained ourself, or the constraint needs updating
        if (!self.aspectRatioHeightConstraint || self.aspectRatioHeightConstraint.multiplier != imageAspectRatio) {
            [self setNeedsUpdateConstraints];
        }
    }
}

- (void) setHighlightedImage:(UIImage *)highlightedImage
{
    [super setHighlightedImage:[self updatedRenderingModeImageFromImage:highlightedImage]];
}

- (void) updateConstraints
{
    if (self.atk_heightConstrainedToAspectWidth && self.image) {
        CGFloat aspectRatioToSet = self.image.size.height / self.image.size.width;
        if (!self.aspectRatioHeightConstraint || self.aspectRatioHeightConstraint.multiplier != aspectRatioToSet) {
            // We haven't constrained ourself, or the constraint needs updating

            // Remove the outdated constraint
            if (self.aspectRatioHeightConstraint) {
                [self removeConstraint:self.aspectRatioHeightConstraint];
                self.aspectRatioHeightConstraint = nil;
            }

            // Create a new constraint based upon the new aspect ratio
            self.aspectRatioHeightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:aspectRatioToSet
                                                                             constant:0.0];
            self.aspectRatioHeightConstraint.priority = UILayoutPriorityDefaultHigh;
            [self addConstraint:self.aspectRatioHeightConstraint];
        }

    } else if (self.aspectRatioHeightConstraint) {
        [self removeConstraint:self.aspectRatioHeightConstraint];
        self.aspectRatioHeightConstraint = nil;
    }

    [super updateConstraints];
}

- (void) setAtk_heightConstrainedToAspectWidth:(BOOL)atk_heightConstrainedToAspectWidth
{
    if (_atk_heightConstrainedToAspectWidth != atk_heightConstrainedToAspectWidth) {
        _atk_heightConstrainedToAspectWidth = atk_heightConstrainedToAspectWidth;
        if (self.image != nil) {
            [self setNeedsUpdateConstraints];
        }
    }
}

@end
