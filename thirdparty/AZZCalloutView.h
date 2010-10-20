//
//  BubbleView.h
//  Slider
//
//  Created by Vladimir Solomenchuk on 10.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AZZCalloutView : UIView 
{
    UIImageView *leftView;
    
    UIImageView *centerView;
    
    UIImageView *rightView;
    
    UIImageView *leftBackgroundView;
    
    UIImageView *rigthBackgroundView;
    
    UIView *contentView;
    
    CGFloat minWidth;
}

-(void) show;
-(void) hide;
@property (readonly) UIView *contentView;
- (CGFloat) optimalWidth:(CGFloat) width;
@end