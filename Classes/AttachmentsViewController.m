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
#import "AttachmentPage.h"

@interface AttachmentsViewController(Private)
- (void) resizePagingScrollView;
- (void) applyNewIndex:(NSInteger)newIndex pageController:(AttachmentPageViewController *)pageController;
- (void) resizeScrollViewAndPages:(UIInterfaceOrientation) orientation;
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
    [currentPage saveContent];
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
    originalWidth = pagingScrollView.frame.size.width;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self resizeScrollViewAndPages:[UIApplication sharedApplication].statusBarOrientation];
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
    [attachment release];

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
    [currentPage setCommenting:isCommenting];
    [nextPage setCommenting:NO];
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
    [self resizeScrollViewAndPages:toInterfaceOrientation];
}

#pragma mark -
#pragma mark methods
-(void) setCommenting:(BOOL) state
{
    isCommenting = state;
    pagingScrollView.canCancelContentTouches = !isCommenting;
    pagingScrollView.delaysContentTouches = !isCommenting;
    [currentPage setCommenting:isCommenting];
    if (!isCommenting) 
        [currentPage saveContent];
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

- (void) resizeScrollViewAndPages:(UIInterfaceOrientation) orientation
{
    CGRect viewRect= pagingScrollView.frame;
    CGFloat heightAdd = -65.0f;
    CGFloat rightPageOffset = 0.0f;
    CGFloat topOffset = 0.0f;
    CGFloat bottomOffset = 0.0f;
    switch (orientation) 
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:    
            heightAdd = -319.0f;
            rightPageOffset = -65.0f;
            break;
        default:
            break;
    }
    
    pagingScrollView.frame = CGRectMake(topOffset, topOffset, viewRect.size.width, originalHeight+heightAdd-topOffset-bottomOffset);    
    currentPage.view.frame = CGRectMake(currentPage.view.frame.origin.x, 0, originalWidth+rightPageOffset, originalHeight+heightAdd);
    nextPage.view.frame = CGRectMake(nextPage.view.frame.origin.x, 0, originalWidth+rightPageOffset, originalHeight+heightAdd);
    [self resizePagingScrollView];
}
@end