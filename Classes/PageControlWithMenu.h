//
//  PageControlWithMenu.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageControlWithMenu : UIPageControl 
{
    UIView *bubbleView;
    UIImageView *backgroundView;
}
@property (nonatomic, retain) UIView *bubbleView;
@property (nonatomic, retain, readonly) UIImageView *backgroundView;
@property NSInteger currentPageBypass;
@end
