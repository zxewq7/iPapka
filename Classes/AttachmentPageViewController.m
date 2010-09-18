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
#import "AttachmentPage.h"

    // This is defined in Math.h
#define M_PI   3.14159265358979323846264338327950288   /* pi */

    // Our conversion definition
#define DEGREES_TO_RADIANS(angle) ((angle / 180.0) * M_PI)


@implementation AttachmentPageViewController
@synthesize pageIndex, attachment;

- (void)setPageIndex:(NSInteger)newPageIndex
{
    pageIndex = newPageIndex;
    
	if (pageIndex >= 0 && pageIndex < [attachment.pages count])
	{		
        AttachmentPage *page = [attachment.pages objectAtIndex:pageIndex];
        [imageView displayImage: page.image angle: DEGREES_TO_RADIANS(page.rotationAngle)];
        
        imageView.drawings = page.drawings;
        
        CGPoint restorePoint = [imageView pointToCenterAfterRotation];
        CGFloat restoreScale = [imageView scaleToRestoreAfterRotation];
        [imageView setMaxMinZoomScalesForCurrentBounds];
        [imageView restoreCenterPoint:restorePoint scale:restoreScale];
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
    else
    {
        [imageView displayImage: nil angle: 0];
        imageView.drawings = nil;
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
		
//        CGPoint restorePoint = [imageView pointToCenterAfterRotation];
//        CGFloat restoreScale = [imageView scaleToRestoreAfterRotation];
//        [imageView setMaxMinZoomScalesForCurrentBounds];
//        [imageView restoreCenterPoint:restorePoint scale:restoreScale];
            
		viewNeedsUpdate = NO;
	}
}

- (void)loadView 
{    
    imageView = [[ImageScrollView alloc] initWithFrame: CGRectZero];
    imageView.paintingDelegate = self;

    self.view = imageView;

    [self.view setOpaque: NO];

}
- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark -
#pragma mark View controller rotation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGPoint restorePoint = [imageView pointToCenterAfterRotation];
    CGFloat restoreScale = [imageView scaleToRestoreAfterRotation];
    [imageView setMaxMinZoomScalesForCurrentBounds];
    [imageView restoreCenterPoint:restorePoint scale:restoreScale];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [imageView release];
    imageView=nil;
}


- (void)dealloc 
{
    [imageView release];
    self.attachment = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark PaintingViewDelegate

-(void) stampAdded:(PaintingView *) sender index:(NSUInteger) anIndex
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *textualMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Textual", "Comment->textual") action:@selector(resetPiece:)];
    UIMenuItem *voiceMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Voice", "Comment->voice") action:@selector(resetPiece:)];

    CGRect commentRect = [[sender.stamps objectAtIndex:anIndex] CGRectValue];
    commentRect.origin.y = 10;
    
    [self becomeFirstResponder];
    [menuController setMenuItems:[NSArray arrayWithObjects:textualMenuItem, voiceMenuItem, nil]];
    [menuController setTargetRect:commentRect inView:sender];
    [menuController setMenuVisible:YES animated:YES];
    
    [textualMenuItem release];
    [voiceMenuItem release];
}

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action == @selector(resetPiece:);
}
-(void) stampTouched:(PaintingView *) sender index:(NSUInteger) anIndex
{
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *textualMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Textual", "Comment->textual") action:@selector(resetPiece:)];
    UIMenuItem *voiceMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Voice", "Comment->voice") action:@selector(resetPiece:)];
    
    CGRect commentRect = [[sender.stamps objectAtIndex:anIndex] CGRectValue];
    
    [self becomeFirstResponder];
    [menuController setMenuItems:[NSArray arrayWithObjects:textualMenuItem, voiceMenuItem, nil]];
    [menuController setTargetRect:commentRect inView:sender];
    [menuController setMenuVisible:YES animated:YES];
    
    [textualMenuItem release];
    [voiceMenuItem release];
}

-(void) setCommenting:(BOOL) state
{
    [imageView setCommenting:state];
}

- (void) saveContent
{
    if (pageIndex >= 0 && pageIndex < [attachment.pages count])
    {
        AttachmentPage *prevPage = [attachment.pages objectAtIndex: pageIndex];
        prevPage.drawings = imageView.drawings;
    }
}

-(void) rotate:(CGFloat) degressAngle
{
    AttachmentPage *page = [attachment.pages objectAtIndex:pageIndex];
    CGFloat angle = page.rotationAngle + degressAngle;
    [imageView rotate: DEGREES_TO_RADIANS(angle)];
    page.rotationAngle = angle;
}

- (void) enablePen:(BOOL) enabled
{
    [imageView enablePen:enabled];
}

- (void) enableMarker:(BOOL) enabled
{
    [imageView enableMarker:enabled];
}

- (void) enableEraser:(BOOL) enabled
{
    [imageView enableEraser:enabled];
}

- (void) enableStamper:(BOOL) enabled
{
    [imageView enableStamper:enabled];
}
@end
