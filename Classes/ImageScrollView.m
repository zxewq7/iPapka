#import "ImageScrollView.h"
#import "PaintingView.h"

#define LANDSCAPE_MAX_WIDTH 1024.0f
#define PORTRAIT_MAX_WIDTH 768.0f

@interface ImageScrollView (Private)
- (void) createSavedPaintingView;
- (void) createPaintingView;
@end


@implementation ImageScrollView
@synthesize painting, paintingDelegate, color, isModified;

- (CGSize) imageSize
{
    return imageOriginalSize;
}

-(BOOL) isModified
{
    return paintingView.isModified;
}

-(void) setColor:(UIColor *) aColor
{
    if (color == aColor)
        return;
    
    [color release];
    color = [aColor retain];
    paintingView.color = color;
}

-(UIImage *) painting
{
    return paintingView?paintingView.image:savedPaintingView.image;
}

-(void) setPainting:(UIImage *) aPainting
{
    if (!(paintingView || savedPaintingView)) 
    {
        if (isCommenting)
            [self createPaintingView];
        else
            [self createSavedPaintingView];
    }
    
    if (paintingView) 
        paintingView.image = aPainting;
    else
        savedPaintingView.image = aPainting;
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
    [savedPaintingView release];
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
        frameToCenter.origin.x = round((boundsSize.width - frameToCenter.size.width) / 2);
    else
        frameToCenter.origin.x = 0;
    
        // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = round((boundsSize.height - frameToCenter.size.height) / 2);
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
    [imageView release]; imageView = nil;
    
    [savedPaintingView removeFromSuperview];
    [savedPaintingView release]; savedPaintingView = nil;
    
    
    [paintingView removeFromSuperview];
    [paintingView release]; paintingView = nil;
    
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
    
    NSUInteger minWidth = ceil(MIN(imageSize.width, boundsSize.width) / 32 ) * 32;
    
    //we need max zoomscales aligned to 32 multplier for drawings
    NSUInteger maxWidth = ceil(minWidth * 1.5f);

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
    CGPoint offset = CGPointMake(boundsCenter.x - round(self.bounds.size.width / 2.0), 
                                 boundsCenter.y - round(self.bounds.size.height / 2.0));
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
        [self createSavedPaintingView];
    
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
- (void) createSavedPaintingView
{
    UIImage *image = paintingView.image;
    
    savedPaintingView = [[UIImageView alloc] initWithImage:image];
    savedPaintingView.frame = CGRectMake(0, 0, imageOriginalSize.width, imageOriginalSize.height);
    
    [paintingView removeFromSuperview];
    [paintingView release]; paintingView = nil;
    
    [imageView addSubview:savedPaintingView];
}

- (void) createPaintingView
{
    //align content size to multiple 32, but not exceed MAX_WIDTH
    //it should be between minimumZoomScale and maximumZoomScale
    
    CGRect imageFrame = imageView.frame;
    CGFloat imageWidth = imageView.image.size.width * self.zoomScale;
    
    NSUInteger newWidth = ceil(imageWidth / 32 ) * 32;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat maxWidth = ((orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)?PORTRAIT_MAX_WIDTH:LANDSCAPE_MAX_WIDTH);

    if (newWidth > maxWidth)
        newWidth = maxWidth;

    CGFloat newScale = (newWidth / imageWidth) * self.zoomScale;
    
    if (newScale > self.maximumZoomScale)
        newScale = self.maximumZoomScale;
    
    self.zoomScale = newScale;
    
    //update imageFrame according to new zoomScale
    imageFrame = imageView.frame;

    UIImage *image = savedPaintingView.image;
    
    paintingView = [[PaintingView alloc] initWithFrame: imageFrame];
    paintingView.backgroundColor = [UIColor clearColor];
    paintingView.paintingDelegate = paintingDelegate;
        //if view can not cancel touchs, than we in editing mode
    paintingView.userInteractionEnabled =  YES;
    paintingView.exclusiveTouch =  YES;

    paintingView.color = self.color;
    
    paintingView.image = image;
    
    [savedPaintingView removeFromSuperview];
    [savedPaintingView release]; savedPaintingView = nil;
    
    [self addSubview:paintingView];
    
}
@end