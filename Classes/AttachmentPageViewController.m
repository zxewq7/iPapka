    //
//  AttachmentPageViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 27.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttachmentPageViewController.h"
#import "Attachment.h"
#import "ImageScrollView.h"


@implementation AttachmentPageViewController
@synthesize pageIndex, attachment;

- (void)setPageIndex:(NSInteger)newPageIndex
{
	pageIndex = newPageIndex;
	
	if (pageIndex >= 0 && pageIndex < [attachment.pages count])
	{		
        [imageView displayImage:[attachment pageForIndex:pageIndex]];
//        CGPoint restorePoint = [imageView pointToCenterAfterRotation];
//        CGFloat restoreScale = [imageView scaleToRestoreAfterRotation];
//        [imageView setMaxMinZoomScalesForCurrentBounds];
//        [imageView restoreCenterPoint:restorePoint scale:restoreScale];
        UIImage *i = [attachment pageForIndex:pageIndex];
        CGSize x = [i size];
        CGSize y = imageView.contentSize;
        CGSize z = self.view.frame.size;
        CGRect m = [[UIScreen mainScreen] bounds];
		CGRect absoluteRect = [self.view.window
                               convertRect:imageView.bounds
                               fromView:imageView];
		if (!self.view.window ||
			!CGRectIntersectsRect(
                                  CGRectInset(absoluteRect, 10, 10),
                                  [self.view.window bounds]))
		{
			viewNeedsUpdate = YES;
		}
	}
}

- (void)updateViews:(BOOL)force
{
	if (force ||
		(viewNeedsUpdate &&
         self.view.window &&
         CGRectIntersectsRect(
                              [self.view.window
                               convertRect:CGRectInset(imageView.bounds, 10, 10)
                               fromView:imageView],
                              [self.view.window bounds])))
	{
		for (UIView *childView in imageView.subviews)
		{
			[childView setNeedsDisplay];
		}
		viewNeedsUpdate = NO;
	}
}
#define LEFT_OFFSET 10.0f
#define RIGHT_OFFSET 75.0f
- (void)viewDidLoad {
    [super viewDidLoad];
    imageView = [[ImageScrollView alloc] init];
    self.view.backgroundColor = [UIColor clearColor];
    imageView.backgroundColor = [UIColor redColor];

    imageView.frame = CGRectMake(LEFT_OFFSET, 0, self.view.frame.size.width-LEFT_OFFSET-RIGHT_OFFSET, self.view.frame.size.height);
    [self.view addSubview:imageView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [imageView release];
    imageView=nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
