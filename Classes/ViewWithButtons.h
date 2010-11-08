//
//  ViewWithButtons.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 18.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewWithButtons : UIView 
{
    NSArray *buttons;
    CGFloat spaceBetweenButtons;
    CGFloat spaceBetweenRows;
    UIControlContentHorizontalAlignment contentHorizontalAlignment;
}

@property (nonatomic, assign) CGFloat spaceBetweenButtons;
@property (nonatomic, assign) CGFloat spaceBetweenRows;
@property (nonatomic, assign) UIControlContentHorizontalAlignment contentHorizontalAlignment;

-(void) setSubviews:(NSArray*) subviews;
@end
