//
//  PageControl.m
//  Slider
//
//  Created by Vladimir Solomenchuk on 18.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PageControl.h"
#import "AZZCalloutView.h"

static NSString *SliderContext = @"SliderContext";

@interface PageControl(Private)
-(void) updateContent;
@end

@implementation PageControl
@synthesize numberOfPages, currentPage;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        self.frame =  frame;
     
        dotImage = [UIImage imageNamed:@"DotNormal.png"];
        [dotImage retain];
        dotSize = dotImage.size;

        
        UIImage *background = [UIImage imageNamed:@"PageControlBackground.png"];
        
        self.bounds = CGRectMake(0,0,frame.size.width, background.size.height);
        
        UIImage *backgroundStretched = [background stretchableImageWithLeftCapWidth:0.0f topCapHeight:0.0f];
        
        CGRect backgroundViewFrame = CGRectMake(0,0,frame.size.width, background.size.height);
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundStretched];
        backgroundView.frame = backgroundViewFrame;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [self addSubview:backgroundView];

        [backgroundView release];
        
        CGRect dotsViewFrame = CGRectMake(0, (self.frame.size.height - dotSize.height)/2, 0, dotSize.height);
        dotsView = [[UIView alloc] initWithFrame:dotsViewFrame];
        dotsView.frame = dotsViewFrame;
        dotsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [self addSubview:dotsView];

        CGRect calloutViewFrame = CGRectMake(0, -50, 100, 57);
        
        calloutView = [[AZZCalloutView alloc] initWithFrame:calloutViewFrame];
        
        calloutView.hidden = YES;
        
        [self addSubview:calloutView];
        
        CGRect sliderFrame = CGRectMake(0,0,frame.size.width, frame.size.height);
        slider = [[UISlider alloc] initWithFrame:sliderFrame];
        slider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [slider setMinimumTrackImage:nil forState:UIControlStateNormal];
        [slider setMaximumTrackImage:nil forState:UIControlStateNormal];
        
        UIImage *knob = [UIImage imageNamed:@"DotCurrent.png"];
        
        [slider setThumbImage:knob forState:UIControlStateNormal];

        [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        [slider addObserver:self forKeyPath:@"tracking" options:NSKeyValueChangeReplacement context:SliderContext];
        
        slider.continuous = YES;

        [self addSubview:slider];
        
        pageNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        pageNumberLabel.backgroundColor = [UIColor clearColor];
        pageNumberLabel.font = [UIFont boldSystemFontOfSize: 14];
        pageNumberLabel.textColor = [UIColor blackColor];
        pageNumberLabel.shadowColor = [UIColor whiteColor];
        pageNumberLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        
        pageNumberLabel.text = @"999 of 999";
        [pageNumberLabel sizeToFit];
        
        CGSize pageNumberLabelSize = pageNumberLabel.frame.size;
        
        pageNumberLabel.frame = CGRectMake(frame.size.width - pageNumberLabelSize.width, (frame.size.height - pageNumberLabelSize.height)/2, pageNumberLabelSize.width, pageNumberLabelSize.height);
        pageNumberLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        pageNumberLabel.text = nil;
        
        [self addSubview:pageNumberLabel];
    }
    return self;
}

- (void)setNumberOfPages:(NSUInteger) number
{
    if (numberOfPages == number)
        return;

    numberOfPages = number;
    
    CGFloat dotsWidth = numberOfPages * dotSize.width;
    CGFloat viewWidth = self.frame.size.width;
    
    if (dotsWidth > viewWidth)
        dotsWidth = dotSize.width * floor(viewWidth / dotSize.width);
    CGRect dotsFrame = dotsView.frame;
    dotsFrame.size.width = dotsWidth;
    dotsFrame.origin.x = (viewWidth - dotsWidth)/2;
    dotsView.frame = dotsFrame;
    slider.frame = dotsFrame;
    
    NSUInteger numberOfDots = floor(dotsWidth / dotSize.width);
    
    for (NSUInteger i = 0; i < numberOfDots; i++)
    {
        UIImageView *dotView = [[UIImageView alloc] initWithImage:dotImage];
        CGRect dotsViewFrame = dotView.frame;
        dotsViewFrame.origin.x = i*dotSize.width;
        dotView.frame = dotsViewFrame;
        [dotsView addSubview: dotView];
    }
    slider.minimumValue = 0;
    slider.maximumValue = numberOfPages - 1;
    slider.value = 0;

    [self updateContent];
}

- (void)setCurrentPage:(NSUInteger) number
{
    [self updateContent];
    [slider setValue:number animated:YES];
}

- (NSUInteger) currentPage
{
    return round(slider.value);
}

-(void)sliderChanged:(id) sender
{
    [self updateContent];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
	if ([keyPath isEqualToString:@"tracking"]) 
    {
        NSArray *svs = [slider subviews];
        if(![svs count])
            return;
        
        UIImageView *sliderThumbView = [[slider subviews] objectAtIndex:2];
        
        CGRect rect = sliderThumbView.frame;
        CGRect calloutViewFrame = calloutView.frame;
        
        calloutViewFrame.origin.x = rect.origin.x - round(calloutViewFrame.size.width / 2) + slider.frame.origin.x + round(rect.size.width / 2);
        calloutViewFrame.origin.y = rect.origin.y - calloutViewFrame.size.height;
        calloutView.frame = calloutViewFrame;
        
        
        if (slider.tracking) 
        {
			if (calloutView.hidden)
				[calloutView show];
		} 
        else
        {
            if (nil != calloutViewTimer) 
            {
                [calloutViewTimer invalidate];
                [calloutViewTimer release]; calloutViewTimer = nil;
            }
            
            calloutViewTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.25f] interval:0.0f target:calloutView selector:@selector(hide) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:calloutViewTimer forMode:NSDefaultRunLoopMode];
        }
	}
}

- (void)dealloc 
{
    [dotsView release]; dotsView = nil;
    
    [dotImage release]; dotImage = nil;
    
    [slider release]; slider = nil;
    
    [calloutView release]; calloutView = nil;

    [calloutViewTimer invalidate];
    [calloutViewTimer release]; calloutViewTimer = nil;
    
    [pageNumberLabel release]; pageNumberLabel = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Private

-(void) updateContent
{
    NSString *pageString = [NSString stringWithFormat: @"%d %@ %d", self.currentPage + 1, NSLocalizedString(@"of", "of"), self.numberOfPages];
    pageNumberLabel.text = pageString;
}
@end
