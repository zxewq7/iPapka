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
@synthesize attachment, currentPage, commenting;

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

#pragma mark -
#pragma mark View loading and unloading

- (void)loadView
{
    UIImage *backgroundImage = [UIImage imageNamed:@"PaperBack.png"];
    
    CGSize imageSize = backgroundImage.size;
    CGRect frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    UIView *v = [[UIView alloc] initWithFrame:frame];
    
    self.view = v;
    
    [v release];
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];

    //prevent black corners 
    //http://stackoverflow.com/questions/1557856/black-corners-on-uitableview-group-style/1559534#1559534
    [self.view setOpaque: NO];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    page1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Paper.png"]];
    //page1 = [[UIView alloc] initWithFrame: CGRectZero];
    page2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
    
    page2.frame = CGRectMake(0, 0, self.view.frame.size.width-10, self.view.frame.size.height-10);
    page1.frame = CGRectMake(0, 0, self.view.frame.size.width-10, self.view.frame.size.height-10);
    
    [self.view addSubview: page2];
    [self.view addSubview: page1];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;

//    [self resizeScrollViewAndPages:[UIApplication sharedApplication].statusBarOrientation];
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
    [tapRecognizer release];
    tapRecognizer = nil;
}

- (void)dealloc
{
    [pagingScrollView release];
    [attachment release];
    [currentPage release];
    [nextPage release];
    [attachment release];
    [tapRecognizer release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

-(void) handleTapFrom:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self.view];
    
    CGSize size = self.view.bounds.size;
    
    BOOL tapBottom = (size.height - location.y)<100.0f;
    
    BOOL tapTop = location.y<100.0f;
    
    if (tapTop || tapBottom)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.75f];
        [UIView setAnimationTransition:tapTop?UIViewAnimationTransitionCurlDown:UIViewAnimationTransitionCurlUp
                               forView:self.view cache:YES];
        if (tapTop)
        {
            if (!page2.superview)
                [self.view addSubview:page2];
            else if (!page1.superview)
                [self.view addSubview:page1];
        }
        else if (tapBottom)
        {
            if (page1.superview)
                [page1 removeFromSuperview];
            else if (page2.superview)
                [page2 removeFromSuperview];
        }
        // Commit the changes
        [UIView commitAnimations];
    }
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
    [currentPage setCommenting:commenting];
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
    return;
    [self resizeScrollViewAndPages:toInterfaceOrientation];
    if ([currentPage respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]) 
        [currentPage willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if ([nextPage respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]) 
        [nextPage willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark methods
-(void) setCommenting:(BOOL) state
{
    commenting = state;
    pagingScrollView.canCancelContentTouches = !commenting;
    pagingScrollView.delaysContentTouches = !commenting;
    [currentPage setCommenting:commenting];
    if (!commenting) 
        [currentPage saveContent];
}

-(void) rotate:(CGFloat) degreesAngle
{
    [currentPage rotate:degreesAngle];
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
	pagingScrollView.contentOffset = CGPointMake(currentPage.pageIndex * pagingScrollView.frame.size.width, 0);
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