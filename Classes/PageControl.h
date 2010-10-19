//
//  PageControl.h
//  Slider
//
//  Created by Vladimir Solomenchuk on 18.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZZCalloutView;
@interface PageControl : UIControl 
{
    UISlider *slider;
    AZZCalloutView *calloutView;
    UILabel *pageNumberLabel;
    UILabel *calloutPageNumberLabel;
    UIView *dotsView;
    
    UIImage *dotImage;
    CGSize dotSize;
    
    UIImageView *knobView;
    
    NSUInteger currentPage;
    NSUInteger numberOfPages;
    
    NSTimer *calloutViewTimer;
}

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger numberOfPages;

-(void) show;
-(void) hide;
@end
