#import "ImageScrollView.h"
#import "PaintingView.h"

#define MAX_WIDTH 1088.0f

@interface ImageScrollView (Private)
- (void) createDrawingsView;
- (void) createPaintingView;
@end


@implementation ImageScrollView
@synthesize drawings, paintingDelegate, color;

-(void) setColor:(UIColor *) aColor
{
    if (color == aColor)
        return;
    
    [color release];
    color = [aColor retain];
    paintingView.color = color;
}

-(UIImage *) drawings
{
    return paintingView?paintingView.image:drawingsView.image;
}

-(void) setDrawings:(UIImage *) aDrawings
{
    if (!(paintingView || drawingsView)) 
    {
        if (isCommenting)
            [self createPaintingView];
        else
            [self createDrawingsView];
    }
    
    if (paintingView) 
        paintingView.image = aDrawings;
    else
        drawingsView.image = aDrawings;
}


- (id<PaintingViewDelegate>) paintingDelegate
{
    return paintingDelegate;
}

-(void) setPaintingDelegate:(id<PaintingViewDelegate>) delegate
{
    if (paintingDelegate == delegate)
        return;
    [paintingDelegate release];
    paintingDelegate = [delegate retain];
    paintingView.paintingDelegate = paintingDelegate;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [imageView release];
    [paintingView release];
    [drawingsView release];
    self.paintingDelegate = nil;
    self.color = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Override layoutSubviews to center content

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
        // center the image as it becomes smaller than the size of the screen
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = imageView.frame;
    
        // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
        // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    imageView.frame = frameToCenter;
}

#pragma mark -
#pragma mark UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

#pragma mark -
#pragma mark Configure scrollView to display new image (tiled or not)

- (void)displayImage:(UIImage *)image angle:(CGFloat) anAngle
{
        // clear the previous imageView
    [imageView removeFromSuperview];
    [imageView release];
    imageView = nil;
    
    [drawingsView removeFromSuperview];
    [drawingsView release];
    drawingsView = nil;
    
    
    [paintingView removeFromSuperview];
    [paintingView release];
    paintingView = nil;
    
        // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
        // make a new UIImageView for the new image
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.userInteractionEnabled =  !isCommenting;
    
    imageOriginalSize = image.size;
    
    [self addSubview:imageView];
    
    self.contentSize = imageOriginalSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
    if (currentAngle != anAngle) 
    {
        currentAngle = anAngle;
        self.transform = CGAffineTransformMakeRotation(0);
        self.transform = CGAffineTransformMakeRotation(currentAngle);
    }
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = imageView.bounds.size;
    
    NSUInteger minWidth = boundsSize.width;
    NSUInteger maxWidth = imageSize.width;

    CGFloat minScale = minWidth / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5.
    CGFloat maxScale = maxWidth / imageSize.width;
    
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale)
        minScale = maxScale;
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

    // returns the center point, in image coordinate space, to try to restore after rotation. 
- (CGPoint)pointToCenterAfterRotation
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    return [self convertPoint:boundsCenter toView:imageView];
}

    // returns the zoom scale to attempt to restore after rotation. 
- (CGFloat)scaleToRestoreAfterRotation
{
    CGFloat contentScale = self.zoomScale;
    
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
    if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
        contentScale = 0;
    
    return contentScale;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

    // Adjusts content offset and scale to try to preserve the old zoomscale and center.
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale
{    
        // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
    
    
        // Step 2: restore center point, first making sure it is within the allowable range.
    
        // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:oldCenter fromView:imageView];
        // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0, 
                                 boundsCenter.y - self.bounds.size.height / 2.0);
        // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
}
-(void) setCommenting:(BOOL) state
{
    if (isCommenting == state)
        return;
    
    isCommenting = state;
    
    if (isCommenting)
        [self createPaintingView];
    else
        [self createDrawingsView];
    
    self.canCancelContentTouches = !isCommenting;
    self.delaysContentTouches = !isCommenting;
}

- (void) rotate:(CGFloat) radiansAngle
{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5f];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    
//        // The transform matrix
//    CGAffineTransform transform = CGAffineTransformMakeRotation(radiansAngle);
//    self.transform = transform;
//    
//        // Commit the changes
//    [UIView commitAnimations];
//    currentAngle = radiansAngle;
}

- (void) enablePen:(BOOL) enabled
{
    [paintingView enablePen:enabled];
}

- (void) enableMarker:(BOOL) enabled
{
    [paintingView enableMarker:enabled];
}
- (void) enableEraser:(BOOL) enabled
{
    [paintingView enableEraser:enabled];
}

- (void) enableStamper:(BOOL) enabled
{
//    [paintingView enableStamper:enabled];
}
@end

@implementation ImageScrollView (Private)
- (void) createDrawingsView
{
    UIImage *image = paintingView.image;
    
    drawingsView = [[UIImageView alloc] initWithImage:image];
    drawingsView.frame = CGRectMake(0, 0, imageOriginalSize.width, imageOriginalSize.height);
    
    [paintingView removeFromSuperview];
    [paintingView release];
    paintingView = nil;
    
    [imageView addSubview:drawingsView];
}

- (void) createPaintingView
{
    //align content size to multiple 32, but not exceed MAX_WIDTH
    
    CGRect imageFrame = imageView.frame;
    
    CGFloat newWidth = (imageFrame.size.width * self.zoomScale) / 32 * 32;
    
    if (newWidth>MAX_WIDTH)
        newWidth = MAX_WIDTH;

    
    CGFloat newScale = newWidth / imageFrame.size.width;
    
    self.zoomScale = newScale;
    
    CGRect f = imageView.frame;

    UIImage *image = drawingsView.image;
    
    paintingView = [[PaintingView alloc] initWithFrame: f];
    paintingView.backgroundColor = [UIColor clearColor];
    paintingView.paintingDelegate = paintingDelegate;
        //if view can not cancel touchs, than we in editing mode
    paintingView.userInteractionEnabled =  YES;
    paintingView.exclusiveTouch =  YES;

    paintingView.color = self.color;
    
    paintingView.image = image;
    
    [drawingsView removeFromSuperview];
    [drawingsView release];
    drawingsView = nil;
    
    [self addSubview:paintingView];
    
}
@end