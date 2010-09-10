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
    UIImage *backgroundImage = [UIImage imageNamed:@"Paper.png"];
    
    CGSize imageSize = backgroundImage.size;
    CGRect frame = CGRectMake(0, 0, imageSize.width, imageSize.height);

    imageView = [[ImageScrollView alloc] initWithFrame: frame];
    imageView.paintingDelegate = self;

    self.view = imageView;
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];
    
    //prevent black corners 
    //http://stackoverflow.com/questions/1557856/black-corners-on-uitableview-group-style/1559534#1559534
    [self.view setOpaque: NO];

}
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
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
    
    [self becomeFirstResponder];
    [menuController setMenuItems:[NSArray arrayWithObjects:textualMenuItem, voiceMenuItem, nil]];
    [menuController setTargetRect:commentRect inView:sender];
    [menuController setMenuVisible:YES animated:YES];
    
    [textualMenuItem release];
    [voiceMenuItem release];
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
