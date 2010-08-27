//
//  AttachmetsViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttachmentsViewController.h"
#import "ImageScrollView.h"
#import "Attachment.h"
#import "AttachmentPageViewController.h"

@interface AttachmentsViewController(Private)
- (void)resizePagingScrollView;
- (void)applyNewIndex:(NSInteger)newIndex pageController:(AttachmentPageViewController *)pageController;
@end


@implementation AttachmentsViewController
@synthesize attachment;

-(void) setAttachment:(Attachment*) anAttachment
{
    if (attachment != anAttachment) 
    {
        [attachment release];
        attachment = [anAttachment retain];
    }
    currentPage.attachment = attachment;
    nextPage.attachment = attachment;
	[self applyNewIndex:0 pageController:currentPage];
	[self applyNewIndex:1 pageController:nextPage];
    [self resizePagingScrollView];
}

-(id)initWithFrame:(CGRect) aFrame
{
    if ((self = [super init])) 
    {
        viewFrame = aFrame;
    }
    return self;
}
#pragma mark -
#pragma mark View loading and unloading

- (void)loadView 
{    
        // Step 1: make the outer paging scroll view
    pagingScrollView = [[UIScrollView alloc] initWithFrame:viewFrame];
    pagingScrollView.pagingEnabled = YES;
    pagingScrollView.backgroundColor = [UIColor clearColor];
    pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.delegate = self;
    self.view = pagingScrollView;
	currentPage = [[AttachmentPageViewController alloc] init];
	nextPage = [[AttachmentPageViewController alloc] init];
	[pagingScrollView addSubview:currentPage.view];
	[pagingScrollView addSubview:nextPage.view];
    originalHeight = pagingScrollView.frame.size.height;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentPage.attachment = attachment;
    nextPage.attachment = attachment;
	[self applyNewIndex:0 pageController:currentPage];
	[self applyNewIndex:1 pageController:nextPage];
    [self resizePagingScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [pagingScrollView release];
    pagingScrollView = nil;
    [currentPage release];
    currentPage = nil;
    [nextPage release];
    nextPage = nil;
}

- (void)dealloc
{
    [pagingScrollView release];
    [attachment release];
    [currentPage release];
    [nextPage release];

    [super dealloc];
}

#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = pagingScrollView.frame.size.width;
    float fractionalPage = pagingScrollView.contentOffset.x / pageWidth;
	
	NSInteger lowerNumber = floor(fractionalPage);
	NSInteger upperNumber = lowerNumber + 1;
	
	if (lowerNumber == currentPage.pageIndex)
	{
		if (upperNumber != nextPage.pageIndex)
		{
			[self applyNewIndex:upperNumber pageController:nextPage];
		}
	}
	else if (upperNumber == currentPage.pageIndex)
	{
		if (lowerNumber != nextPage.pageIndex)
		{
			[self applyNewIndex:lowerNumber pageController:nextPage];
		}
	}
	else
	{
		if (lowerNumber == nextPage.pageIndex)
		{
			[self applyNewIndex:upperNumber pageController:currentPage];
		}
		else if (upperNumber == nextPage.pageIndex)
		{
			[self applyNewIndex:lowerNumber pageController:currentPage];
		}
		else
		{
			[self applyNewIndex:lowerNumber pageController:currentPage];
			[self applyNewIndex:upperNumber pageController:nextPage];
		}
	}
	
	[currentPage updateViews:NO];
	[nextPage updateViews:NO];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)newScrollView
{
    CGFloat pageWidth = pagingScrollView.frame.size.width;
    float fractionalPage = pagingScrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
    
	if (currentPage.pageIndex != nearestNumber)
	{
		AttachmentPageViewController *swapController = currentPage;
		currentPage = nextPage;
		nextPage = swapController;
	}
    
	[currentPage updateViews:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)newScrollView
{
	[self scrollViewDidEndScrollingAnimation:newScrollView];
	NSInteger pageIndex = currentPage.pageIndex;
    
        // update the scroll view to the appropriate page
    CGRect frame = pagingScrollView.frame;
    frame.origin.x = frame.size.width * pageIndex;
    frame.origin.y = 0;
    [pagingScrollView scrollRectToVisible:frame animated:YES];
}

#pragma mark -
#pragma mark View controller rotation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
        // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
        // place to calculate the content offset that we will need in the new orientation
//    CGFloat offset = pagingScrollView.contentOffset.x;
//    CGFloat pageWidth = pagingScrollView.bounds.size.width;
//    
//    if (offset >= 0) {
//        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
//        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
//    } else {
//        firstVisiblePageIndexBeforeRotation = 0;
//        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
//    }    
    CGRect viewRect= pagingScrollView.frame;
    CGFloat heightAdd = 0.0f;
    switch (toInterfaceOrientation) 
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:    
            heightAdd = -274.0f;
            break;
        default:
            break;
    }
    
    
    pagingScrollView.frame = CGRectMake(viewRect.origin.x, viewRect.origin.y, viewRect.size.width, originalHeight+heightAdd);    
    currentPage.view.frame = CGRectMake(0, 0, viewRect.size.width, originalHeight+heightAdd);
    nextPage.view.frame = CGRectMake(0, 0, viewRect.size.width, originalHeight+heightAdd);
    [currentPage updateViews:NO];
    [nextPage updateViews:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
        // recalculate contentSize based on current orientation
//    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
//    
//        // adjust frames and configuration of each visible page
//    for (ImageScrollView *page in visiblePages) {
//        CGPoint restorePoint = [page pointToCenterAfterRotation];
//        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
//        page.frame = [self frameForPageAtIndex:page.index];
//        [page setMaxMinZoomScalesForCurrentBounds];
//        [page restoreCenterPoint:restorePoint scale:restoreScale];
//        
//    }
//    
//        // adjust contentOffset to preserve page location based on values collected prior to location
//    CGFloat pageWidth = pagingScrollView.bounds.size.width;
//    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
//    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}
@end

@implementation AttachmentsViewController(Private)

- (void)applyNewIndex:(NSInteger)newIndex pageController:(AttachmentPageViewController *)pageController;
{
	NSInteger pageCount = [attachment.pages count];
	BOOL outOfBounds = newIndex >= pageCount || newIndex < 0;
    
	if (!outOfBounds)
	{
		CGRect pageFrame = pageController.view.frame;
		pageFrame.origin.y = 0;
		pageFrame.origin.x = pagingScrollView.frame.size.width * newIndex;
		pageController.view.frame = pageFrame;
	}
	else
	{
		CGRect pageFrame = pageController.view.frame;
		pageFrame.origin.y = pagingScrollView.frame.size.height;
		pageController.view.frame = pageFrame;
	}
    
	pageController.pageIndex = newIndex;
}

- (void)resizePagingScrollView
{
	NSInteger widthCount = [attachment.pages count];
	if (widthCount == 0)
	{
		widthCount = 1;
	}
	
    pagingScrollView.contentSize =
    CGSizeMake(
               pagingScrollView.frame.size.width * widthCount,
               pagingScrollView.frame.size.height);
	pagingScrollView.contentOffset = CGPointMake(0, 0);
}
@end