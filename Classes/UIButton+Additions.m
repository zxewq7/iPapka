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
                 imageName:(NSString *)anImageName
         imageNameSelected:(NSString *)anImageNameSelected

{
    UIImage *normal = [UIImage imageNamed:anImageName];
    UIImage *selected = [UIImage imageNamed:anImageNameSelected];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.bounds = CGRectMake( 0, 0, normal.size.width, normal.size.height );    
    
    [button setImage:normal forState:UIControlStateNormal];
    [button setImage:selected forState:UIControlStateSelected];
    
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+(UIButton *) imageButtonWithTitle:(NSString *) title
                            target:(id)target
                          selector:(SEL)selector
                             imageName:(NSString *)anImageName
                     imageNameSelected:(NSString *)anImageNameSelected
{
#define kStdButtonWidth		106.0
#define kStdButtonHeight	40.0
    
    UIButton *button = [UIButton imageButton:target
                                    selector:selector
                                   imageName:anImageName
                           imageNameSelected:anImageNameSelected];
	button.frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.000 green:0.596 blue:0.992 alpha:1.0] forState:UIControlStateSelected];
    
    [button setTitle:title forState:UIControlStateNormal];
    
        // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor]; 
    return button;
}
@end
