//
//  ViewWithButtons.h
//  Meester
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
    UIControlContentVerticalAlignment contentVerticalAlignment;
}

@property (nonatomic, retain) NSArray *buttons;
@property (nonatomic, assign) CGFloat spaceBetweenButtons;
@property (nonatomic, assign) CGFloat spaceBetweenRows;
@property (nonatomic, assign) UIControlContentVerticalAlignment contentVerticalAlignment;

@end
