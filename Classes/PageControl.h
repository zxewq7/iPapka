//
//  PageControl.h
//  Slider
//
//  Created by Vladimir Solomenchuk on 18.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageControl;
@protocol PageControlDelegate<NSObject>

-(NSArray*) pageControl:(PageControl *) aPageControl iconsForPage:(NSUInteger) aPage;

@end

@class AZZCalloutView;
@interface PageControl : UIControl 
{
    UISlider *slider;
    AZZCalloutView *calloutView;
    UILabel *titleLabel;
    UILabel *calloutTitleLabel;
    UIView *dotsView;
    
    UIImage *dotImage;
    CGSize dotSize;
    
    UIImageView *knobView;
    
    NSUInteger currentPage;
    NSUInteger numberOfPages;
    
    NSTimer *calloutViewTimer;
    
    id<PageControlDelegate> delegate;
    
    UIView *calloutIconsView;
}

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, retain) id<PageControlDelegate> delegate;

-(void) hide:(BOOL) hide animated:(BOOL) animated;
@end
