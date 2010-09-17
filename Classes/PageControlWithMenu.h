//
//  PageControlWithMenu.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
// http://www.onidev.com/2009/12/02/customisable-uipagecontrol/
//

#import <Foundation/Foundation.h>

@interface PageControlWithMenu : UIPageControl 
{
    UIView *bubbleView;
    UIImageView *backgroundView;
    UIImage* dotNormal;
    UIImage* dotCurrent;
    CGSize dotSize;
    UILabel* pagesCounter;
}
@property (nonatomic, retain) UIView *bubbleView;
@property (nonatomic, retain, readonly) UIImageView *backgroundView;
@property (nonatomic, readwrite, retain) UIImage* dotNormal;
@property (nonatomic, readwrite, retain) UIImage* dotCurrent;
@property (nonatomic, readwrite, retain) UILabel* label;
@end
