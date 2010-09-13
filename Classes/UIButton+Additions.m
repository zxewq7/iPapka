//
//  UIButton+Additions.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 28.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIButton+Additions.h"


@implementation UIButton (Button_Additions)
+ (UIButton *) imageButton:(id)target
                  selector:(SEL)selector
                     image:(UIImage *)anImage
             imageSelected:(UIImage *)anImageSelected

{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.bounds = CGRectMake( 0, 0, anImage.size.width, anImage.size.height );    
    
    [button setImage:anImage forState:UIControlStateNormal];
    [button setImage:anImageSelected forState:UIControlStateSelected];
    
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+(UIButton *) imageButtonWithTitle:(NSString *) title
                            target:(id)target
                          selector:(SEL)selector
                             image:(UIImage *)anImage
                     imageSelected:(UIImage *)anImageSelected
{
#define kStdButtonWidth		106.0
#define kStdButtonHeight	40.0
    
    UIButton *button = [UIButton imageButton:target
                                    selector:selector
                                       image:anImage
                               imageSelected:anImageSelected];
    CGFloat width = button.frame.size.width + [title sizeWithFont:[UIFont boldSystemFontOfSize: 17]].width;
	button.frame = CGRectMake(182.0, 5.0, width, kStdButtonHeight);
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.000 green:0.596 blue:0.992 alpha:1.0] forState:UIControlStateSelected];
    
    [button setTitle:title forState:UIControlStateNormal];
    
        // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor]; 
    return button;
}

+ (UIButton *)buttonWithBackgroundAndTitle:(NSString *)title
                                 titleFont:(UIFont *) titleFont
                                    target:(id)target
                                  selector:(SEL)selector
                                     frame:(CGRect)frame
                             addLabelWidth:(BOOL)addLabelWidth
                                     image:(UIImage *)image
                              imagePressed:(UIImage *)imagePressed
                             darkTextColor:(BOOL)darkTextColor
{	
    CGFloat width = addLabelWidth?[title sizeWithFont:titleFont].width:0;
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.x, frame.size.width + width, frame.size.height)];
	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
    button.titleLabel.font = titleFont;
    
	[button setTitle:title forState:UIControlStateNormal];	
    [button setTitleColor: darkTextColor?[UIColor blackColor]:[UIColor whiteColor] forState:UIControlStateNormal];
    
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newPressedImage forState:UIControlStateSelected];
    [button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	
	return button;
}
@end
