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
@interface AttachmentsViewController(Private)
- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;

- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;

- (void)tilePages;
- (ImageScrollView *)dequeueRecycledPage;

- (NSUInteger)imageCount;
- (CGSize)imageSizeAtIndex:(NSUInteger)index;
- (UIImage *)imageAtIndex:(NSUInteger)index;
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
    [recycledPages removeAllObjects];
    [visiblePages removeAllObjects];
    NSArray *subviews = pagingScrollView.subviews;
    for (UIView *view in subviews)
        [view removeFromSuperview];
    
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self tilePages];
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
    pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    pagingScrollView.delegate = self;
    self.view = pagingScrollView;
    
        // Step 2: prepare to tile content
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages  = [[NSMutableSet alloc] init];
    [self tilePages];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [pagingScrollView release];
    pagingScrollView = nil;
    [recycledPages release];
    recycledPages = nil;
    [visiblePages release];
    visiblePages = nil;
}

- (void)dealloc
{
    [pagingScrollView release];
    [attachment release];
    [super dealloc];
}

#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tilePages];
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
    CGFloat offset = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    
    if (offset >= 0) {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else {
        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
        // recalculate contentSize based on current orientation
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
        // adjust frames and configuration of each visible page
    for (ImageScrollView *page in visiblePages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
        
    }
    
        // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}
@end

@implementation AttachmentsViewController(Private)
#pragma mark -
#pragma mark Tiling and page configuration

- (void)tilePages 
{
        // Calculate which pages are visible
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self imageCount] - 1);
    
        // Recycle no-longer-visible pages 
    for (ImageScrollView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
        // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ImageScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[[ImageScrollView alloc] init] autorelease];
            }
            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }    
}

- (ImageScrollView *)dequeueRecycledPage
{
    ImageScrollView *page = [recycledPages anyObject];
    if (page) {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ImageScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void)configurePage:(ImageScrollView *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    
        // Use tiled images
        //    [page displayTiledImageNamed:[self imageNameAtIndex:index]
        //                            size:[self imageSizeAtIndex:index]];
    
        // To use full images instead of tiled images, replace the "displayTiledImageNamed:" call
        // above by the following line:
    [page displayImage:[self imageAtIndex:index]];
}

#pragma mark -
#pragma mark  Frame calculations
#define PADDING  0

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
        // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
        // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
        // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
        // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
        // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self imageCount], bounds.size.height);
}


#pragma mark -
#pragma mark Image wrangling
- (UIImage *)imageAtIndex:(NSUInteger)index {
        // use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching our images
    return [attachment pageForIndex:index];  
}

- (CGSize)imageSizeAtIndex:(NSUInteger)index {
    CGSize size = CGSizeZero;
    if (index < [self imageCount])
        size = [self imageAtIndex:index].size;
    
    return size;
}

- (NSUInteger)imageCount {
    return [attachment.pages count];
}
@end