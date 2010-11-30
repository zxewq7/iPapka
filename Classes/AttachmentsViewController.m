//
//  AttachmetsViewController.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttachmentsViewController.h"
#import "ImageScrollView.h"
#import "Attachment.h"
#import "AttachmentPageViewController.h"
#import "AttachmentPage.h"

typedef enum _TapPosition{
    TapPositionTop = 0,
    TapPositionMiddle = 1,
    TapPositionBottom = 2
} TapPosition;

@interface AttachmentsViewController(Private)
- (TapPosition) tapPosition:(CGPoint) location;
- (void) setPages:(NSInteger) direction;
- (void) setPageZoomScale:(AttachmentPageViewController *) pageController;
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
    
    currentPage.color = paintingTools.color;
    nextPage.color = paintingTools.color;
}

-(void) setPageControl:(PageControl *) aPageControl
{
    if (pageControl == aPageControl)
        return;
    [pageControl removeTarget:self action:@selector(pageAction:) forControlEvents:UIControlEventValueChanged];
    [pageControl release];
    pageControl = [aPageControl retain];
    [pageControl addTarget:self action:@selector(pageAction:) forControlEvents:UIControlEventValueChanged];
    pageControl.numberOfPages = [attachment.pagesOrdered count];
    pageControl.hidden = YES;
    pageControl.delegate = self;
}

-(void) setAttachment:(Attachment *) anAttachment
{
    [currentPage saveContent];
    
    if (attachment != anAttachment)
    {
        [attachment release];
        attachment = [anAttachment retain];
    }
  
    pageControl.numberOfPages = [attachment.pagesOrdered count];
    pageControl.currentPage = 0;
    
    [self setPages:1];
}

#pragma mark -
#pragma mark View loading and unloading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageSize = CGSizeZero;
    zoomScale = 0.f;

    
    self.view.autoresizesSubviews = YES;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"PaperTexture.png"]];

    //tap recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapRecognizer.delegate = self;

    [self.view addGestureRecognizer:tapRecognizer];
    
    [tapRecognizer release];

    //create pages
    currentPage = [[AttachmentPageViewController alloc] init];
	nextPage = [[AttachmentPageViewController alloc] init];

    nextPage.view.hidden = YES;
    
    CGRect pageFrame = self.view.bounds;
    currentPage.view.frame = pageFrame;
    nextPage.view.frame = pageFrame;
    
    currentPage.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                         UIViewAutoresizingFlexibleWidth);
    nextPage.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                      UIViewAutoresizingFlexibleWidth);

    currentPage.color = paintingTools.color;
    nextPage.color = paintingTools.color;
    
    [self.view addSubview:nextPage.view];
	[self.view addSubview:currentPage.view];
    
    //refresh pages
    self.attachment = self.attachment;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [currentPage release]; currentPage = nil;
    [nextPage release]; nextPage = nil;
}

- (void)dealloc
{
    [attachment release]; attachment = nil;
    
    [currentPage release]; currentPage = nil;
    
    [nextPage release]; nextPage = nil;
    
    self.pageControl = nil;
    
    self.attachment = nil;
    
    self.paintingTools = nil;
    
    [super dealloc];
}

-(void)pageAction:(id) sender
{
    NSUInteger currentIndex = pageControl.currentPage;
	
    if (currentPage.page.number.integerValue != currentIndex)
    {
        BOOL down = currentIndex > currentPage.page.number.integerValue;

        [self setPages:(down?1:-1)];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition: (!down?UIViewAnimationTransitionCurlDown:UIViewAnimationTransitionCurlUp)
                               forView:self.view cache:YES];

        // Commit the changes
        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark PageControlDelegate
-(NSArray*) pageControl:(PageControl *) aPageControl iconsForPage:(NSUInteger) aPage
{
    AttachmentPage *page = [attachment.pagesOrdered objectAtIndex: aPage];
    
    if (page.hasPaintings)
        return [NSArray arrayWithObject:[UIImage imageNamed:@"IconComment.png"]];
    
    return nil;
}

#pragma mark -
#pragma mark PaintingToolsDelegate

-(void) paintingView: (PaintingToolsViewController *) sender color:(UIColor *) aColor
{
    currentPage.color = aColor;
	nextPage.color = aColor;
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
        default:
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
    if (!self.attachment || commenting) //do not show pager or switch pages if attachment is nil or we are in commenting mode
        return NO;
        
    TapPosition tapPosition = [self tapPosition:[touch locationInView:self.view]];
    
    if (tapPosition == TapPositionMiddle)
        return YES;

    return pageControl.hidden;
}

-(void) handleTapFrom:(UIGestureRecognizer *)gestureRecognizer
{
    TapPosition tapPosition = [self tapPosition:[gestureRecognizer locationInView:self.view]];
    
    if (tapPosition == TapPositionMiddle) //fade in/out pageControl
        [pageControl hide:!pageControl.hidden animated:YES];
    else if (tapPosition == TapPositionTop || tapPosition == TapPositionBottom)
    {
        NSInteger currentIndex = currentPage.page.number.integerValue + (tapPosition == TapPositionTop?-1:1);

        NSUInteger numberOfPages = pageControl.numberOfPages-1;
        
        if (currentIndex < 0 || currentIndex > numberOfPages) //out of bounds
            return;
        
        pageControl.currentPage = currentIndex;
        
        //emulate pager tap
        [self pageAction:pageControl];
    }
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
    [currentPage setCommenting:commenting];
}
@end

@implementation AttachmentsViewController(Private)
- (TapPosition) tapPosition:(CGPoint) location
{
    CGSize size = self.view.frame.size;
    
    if ((size.height - location.y) < 100.0f)
        return TapPositionBottom;
    
    if (location.y < 100.0f)
        return TapPositionTop;

    return TapPositionMiddle;
}

- (void) setPages:(NSInteger) direction
{
        //cancel all paintings
    [paintingTools cancel];
    
    NSUInteger numberOfPages = pageControl.numberOfPages;
    NSInteger currentIndex = pageControl.currentPage;
    
    if (0 <= currentIndex && currentIndex < numberOfPages)
    {
        zoomScale = currentPage.zoomScale;
        imageSize = currentPage.imageSize;
        
        if (nextPage.page && currentIndex == nextPage.page.number.integerValue)
        {
            AttachmentPageViewController *swapController = currentPage;
            currentPage = nextPage;
            nextPage = swapController;
        }
        else
            currentPage.page = [attachment.pagesOrdered objectAtIndex: currentIndex];
        
        NSInteger nextIndex = currentIndex + direction;
        
        if (0 <= nextIndex && nextIndex < numberOfPages)
            nextPage.page = [attachment.pagesOrdered objectAtIndex: nextIndex];
        else
            nextPage.page = nil;

		[self setPageZoomScale:currentPage];
		[self setPageZoomScale:nextPage];
    }
    else
    {
        currentPage.page = nil;
        nextPage.page = nil;
    }
    
    nextPage.view.hidden = YES;
    currentPage.view.hidden = NO;
    
    paintingTools.view.hidden = !currentPage.page.isEditable;
}
- (void) setPageZoomScale:(AttachmentPageViewController *) pageController
{
        //determine optimal zoomScale
    CGFloat widthDifference = imageSize.width * 0.1;
    CGSize currentImageSize = pageController.imageSize;
    
    if ( ((imageSize.width - widthDifference) <= currentImageSize.width) &&
        ((imageSize.width + widthDifference) >= currentImageSize.width))
        pageController.zoomScale = zoomScale;    
}
@end
