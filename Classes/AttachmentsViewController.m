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
#import "PageControlWithMenu.h"
#import "Document.h"
#import "DataSource.h"

static NSString *HidePageControlAnimationId = @"HidePageControlAnimationId";

typedef enum _TapPosition{
    TapPositionTop = 0,
    TapPositionMiddle = 1,
    TapPositionBottom = 2
} TapPosition;

@interface AttachmentsViewController(Private)
- (TapPosition) tapPosition:(UITouch *)touch;
- (void) setPages;
@end

@implementation AttachmentsViewController
@synthesize commenting, pageControl, attachment, paintingTools;

-(void) setPaintingTools: (PaintingToolsViewController *) aPaintingTools
{
    if (aPaintingTools == paintingTools)
        return;
    
    [paintingTools release];
    paintingTools = [aPaintingTools retain];
    paintingTools.delegate = self;
}

-(void) setPageControl:(PageControlWithMenu *) aPageControl
{
    if (pageControl == aPageControl)
        return;
    [pageControl removeTarget:self action:@selector(pageAction:) forControlEvents:UIControlEventTouchUpInside];
    [pageControl release];
    pageControl = [aPageControl retain];
    [pageControl addTarget:self action:@selector(pageAction:) forControlEvents:UIControlEventTouchUpInside];
    pageControl.numberOfPages = [attachment.pagesOrdered count];
    pageControl.hidden = YES;
    pageControl.alpha = 0.0;
}

-(void) setAttachment:(Attachment *) anAttachment
{
    
    if (attachment == anAttachment)
        return;
    
    [attachment release];
    attachment = [anAttachment retain];
  
    [currentPage saveContent];

    pageControl.numberOfPages = [attachment.pagesOrdered count];
    pageControl.currentPage = 0;
    
    [self setPages];
}

#pragma mark -
#pragma mark View loading and unloading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizesSubviews = YES;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"PaperTexture.png"]];

    //tap recognizer
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;

    //create pages
    currentPage = [[AttachmentPageViewController alloc] init];
	nextPage = [[AttachmentPageViewController alloc] init];

    nextPage.view.hidden = YES;
    
    CGSize size = self.view.frame.size;
    CGRect pageFrame = CGRectMake(0, 0, size.width, size.height);
    currentPage.view.frame = pageFrame;
    nextPage.view.frame = pageFrame;
    
    currentPage.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                         UIViewAutoresizingFlexibleWidth);
    nextPage.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                      UIViewAutoresizingFlexibleWidth);

    currentPage.color = paintingTools.color;
    nextPage.color = paintingTools.color;
    
    //refrest pages
    self.attachment = self.attachment;
    
    [self.view addSubview:nextPage.view];
	[self.view addSubview:currentPage.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [currentPage release]; currentPage = nil;
    [nextPage release]; nextPage = nil;
    [tapRecognizer release]; tapRecognizer = nil;
}

- (void)dealloc
{
    [attachment release];
    attachment = nil;
    
    [currentPage release];
    currentPage = nil;
    
    [nextPage release];
    nextPage = nil;
    
    [tapRecognizer release];
    tapRecognizer = nil;
    
    self.pageControl = nil;
    
    self.attachment = nil;
    
    self.paintingTools = nil;
    
    [super dealloc];
}

-(void)pageAction:(id) sender
{
    NSUInteger currentIndex = pageControl.currentPage;
    
    if (currentPageIndex != currentIndex)
    {
        BOOL nextPrev = currentIndex < currentPageIndex;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition: (nextPrev?UIViewAnimationTransitionCurlDown:UIViewAnimationTransitionCurlUp)
                               forView:self.view cache:YES];
        if (nextPrev) //page up
        {
            AttachmentPageViewController *swapController = currentPage;
            currentPage = nextPage;
            nextPage = swapController;
            [self setPages];
        }
        else //page down
        {
            AttachmentPageViewController *swapController = currentPage;
            currentPage = nextPage;
            nextPage = swapController;
            [self setPages];
        }
        nextPage.view.hidden = YES;
        currentPage.view.hidden = NO;
        // Commit the changes
        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark PaintingToolsDelegate

-(void) paintingView: (PaintingToolsViewController *) sender color:(UIColor *) aColor
{
    currentPage.color = aColor;
}

-(void) paintingView: (PaintingToolsViewController *) sender tool: (PaintingTool) aTool
{
    self.commenting = (aTool != PaintingToolNone);
    switch (aTool)
    {
        case PaintingToolComment:
            currentPage.stamper = YES;
            break;
        case PaintingToolEraser:
            currentPage.eraser = YES;
            break;
        case PaintingToolMarker:
            currentPage.marker = YES;
            break;
        case PaintingToolPen:
            currentPage.pen = YES;
            break;
    }
}

-(void) paintingView: (PaintingToolsViewController *) sender rotate: (CGFloat) degreesAngle;
{
    currentPage.angle = degreesAngle;
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    TapPosition tapPosition = [self tapPosition:touch];
    
    if (tapPosition == TapPositionMiddle)
        return YES;

    return pageControl.hidden;
}

-(void) handleTapFrom:(UITouch *)touch
{
    TapPosition tapPosition = [self tapPosition:touch];
    
    if (tapPosition == TapPositionMiddle)
    {
        //fade in/out pageControl
        [UIView beginAnimations:HidePageControlAnimationId context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view.window cache:YES];
        [UIView setAnimationDelegate:self]; 
        [UIView setAnimationDidStopSelector:@selector(animationDidStopped:finished:context:)];
        if (pageControl.hidden)
            pageControl.hidden = NO;
        pageControl.alpha = pageControl.alpha == 0.0?1.0:0.0;
        [UIView commitAnimations];

    }
    else if (tapPosition == TapPositionTop || tapPosition == TapPositionBottom)
    {
        NSInteger currentIndex = currentPageIndex + (tapPosition == TapPositionTop?-1:1);

        NSUInteger numberOfPages = pageControl.numberOfPages-1;
        
        if (currentPageIndex<0 || currentPageIndex>numberOfPages) //out of bounds
            return;
        pageControl.currentPage = currentIndex;
        
        //emulate pager tap
        [self pageAction:pageControl];
    }
}

- (void)animationDidStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (animationID == HidePageControlAnimationId)
        pageControl.hidden = (pageControl.alpha == 0.0);
}
#pragma mark -
#pragma mark View controller rotation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([currentPage respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)])
    {
        [currentPage willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
        [nextPage willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}
#pragma mark -
#pragma mark methods
-(void) setCommenting:(BOOL) state
{
    commenting = state;
//    pagingScrollView.canCancelContentTouches = !commenting;
//    pagingScrollView.delaysContentTouches = !commenting;
    [currentPage setCommenting:commenting];
    if (!commenting)
    {
        [currentPage saveContent];
        [[DataSource sharedDataSource] commit];
    }
}
@end

@implementation AttachmentsViewController(Private)
- (TapPosition) tapPosition:(UITouch *)touch
{
    CGSize size = self.view.frame.size;
    CGPoint location = [touch locationInView:self.view];
    
    if ((size.height - location.y)<100.0f)
        return TapPositionBottom;
    
    if (location.y<100.0f)
        return TapPositionTop;

    return TapPositionMiddle;
}
- (void) setPages
{
    NSUInteger numberOfPages = pageControl.numberOfPages;
    NSUInteger currentIndex = pageControl.currentPage;
    
    if (numberOfPages > currentIndex)
    {
        currentPage.page = [attachment.pagesOrdered objectAtIndex: currentIndex];
        currentPageIndex = currentIndex;
        
        if (numberOfPages > (currentIndex + 1))
            nextPage.page = [attachment.pagesOrdered objectAtIndex: (currentIndex + 1)];
        else
            nextPage.page = nil;
    }
    else
    {
        currentPage.page = nil;
        nextPage.page = nil;
    }
}
@end
