    //
//  AttachmentPageViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 27.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttachmentPageViewController.h"
#import "ImageScrollView.h"
#import "AttachmentPage.h"
#import "AttachmentPagePainting.h"
#import "DataSource.h"


    // This is defined in Math.h
#define M_PI   3.14159265358979323846264338327950288   /* pi */

    // Our conversion definition
#define DEGREES_TO_RADIANS(angle) ((angle / 180.0) * M_PI)


@implementation AttachmentPageViewController
@synthesize page;
@dynamic pen, stamper, eraser, marker, angle;
@dynamic color;

- (void)setPage:(AttachmentPage *)aPage
{
    if (page == aPage)
        return;

    [self saveContent];

    [page release];
    page = [aPage retain];
    
    [imageView displayImage: page.image angle: DEGREES_TO_RADIANS(page.angleValue)];
    
    imageView.painting = page.painting.image;
    
    CGPoint restorePoint = [imageView pointToCenterAfterRotation];
    CGFloat restoreScale = [imageView scaleToRestoreAfterRotation];
    [imageView setMaxMinZoomScalesForCurrentBounds];
    [imageView restoreCenterPoint:restorePoint scale:restoreScale];
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
    self.page = nil;
    self.color = nil;
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
    if (!state)
        [self saveContent];
    
    [imageView setCommenting:state];
}

- (void) saveContent
{
    if (imageView.isModified)
    {
        NSString *paintingPath = page.painting.path;
        UIImage *painting = imageView.painting;
        
        if (painting)
        {
            NSData *paintingData = UIImagePNGRepresentation(painting);
            [paintingData writeToFile: paintingPath atomically:YES];
            page.painting.dateModified = [NSDate date];
            [[DataSource sharedDataSource] commit];
        }
    }
}

- (void) setPen:(BOOL) enabled
{
    [imageView enablePen:enabled];
}

- (void) setMarker:(BOOL) enabled
{
    [imageView enableMarker:enabled];
}

- (void) setEraser:(BOOL) enabled
{
    [imageView enableEraser:enabled];
}

- (void) setStamper:(BOOL) enabled
{
    [imageView enableStamper:enabled];
}

-(void) setAngle:(CGFloat) anAngle
{
    CGFloat angle = page.angleValue + anAngle;
    [imageView rotate: DEGREES_TO_RADIANS(angle)];
    page.angleValue = angle;
}

- (void) setColor:(UIColor *) aColor
{
    imageView.color = aColor;
}

- (UIColor *) color
{
    return imageView.color;
}
@end
