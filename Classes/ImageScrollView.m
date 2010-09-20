#import "ImageScrollView.h"
#import "PaintingView.h"

#define MAX_WIDTH 1088.0f

    //FUNCTIONS:
/*
 HSL2RGB Converts hue, saturation, luminance values to the equivalent red, green and blue values.
 For details on this conversion, see Fundamentals of Interactive Computer Graphics by Foley and van Dam (1982, Addison and Wesley)
 You can also find HSL to RGB conversion algorithms by searching the Internet.
 See also http://en.wikipedia.org/wiki/HSV_color_space for a theoretical explanation
 */
static void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
	float			temp1,
    temp2;
	float			temp[3];
	int				i;
	
        // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
	if(s == 0.0) {
		if(outR)
			*outR = l;
		if(outG)
			*outG = l;
		if(outB)
			*outB = l;
		return;
	}
	
        // Test for luminance and compute temporary values based on luminance and saturation 
	if(l < 0.5)
		temp2 = l * (1.0 + s);
	else
		temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;
	
        // Compute intermediate values based on hue
	temp[0] = h + 1.0 / 3.0;
	temp[1] = h;
	temp[2] = h - 1.0 / 3.0;
    
	for(i = 0; i < 3; ++i) {
		
            // Adjust the range
		if(temp[i] < 0.0)
			temp[i] += 1.0;
		if(temp[i] > 1.0)
			temp[i] -= 1.0;
		
		
		if(6.0 * temp[i] < 1.0)
			temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
		else {
			if(2.0 * temp[i] < 1.0)
				temp[i] = temp2;
			else {
				if(3.0 * temp[i] < 2.0)
					temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
				else
					temp[i] = temp1;
			}
		}
	}
	
        // Assign temporary values to R, G, B
	if(outR)
		*outR = temp[0];
	if(outG)
		*outG = temp[1];
	if(outB)
		*outB = temp[2];
}
#define kPaletteSize			5

@interface ImageScrollView (Private)
- (void) createDrawingsView;
- (void) createPaintingView;
@end


@implementation ImageScrollView
@synthesize drawings, paintingDelegate;

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
    
    NSUInteger imageWidth = imageSize.width;

    NSUInteger minWidth = (boundsSize.width/32)*32;
    NSUInteger maxWidth = (imageWidth/32)*32;

    if (maxWidth>MAX_WIDTH)
        maxWidth = MAX_WIDTH;

    if (minWidth > maxWidth)
        maxWidth = minWidth;
    
    CGFloat minScale = minWidth / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5.
        //
        //due to odd behavoir fo grReadPixels we need exact width (checked 1024, 537-544, 320)
    CGFloat maxScale = maxWidth / imageSize.width;
    
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
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
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
        // The transform matrix
    CGAffineTransform transform = CGAffineTransformMakeRotation(radiansAngle);
    self.transform = transform;
    
        // Commit the changes
    [UIView commitAnimations];
    currentAngle = radiansAngle;
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
    [paintingView enableStamper:enabled];
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
    UIImage *image = drawingsView.image;
    
    CGRect f = imageView.frame;
    paintingView = [[PaintingView alloc] initWithFrame: f];
    paintingView.backgroundColor = [UIColor clearColor];
    paintingView.paintingDelegate = paintingDelegate;
        //if view can not cancel touchs, than we in editing mode
    paintingView.userInteractionEnabled =  YES;
    paintingView.exclusiveTouch =  YES;

    CGFloat					components[3];
    
    HSL2RGB((CGFloat)0 / (CGFloat)kPaletteSize, kSaturation, kLuminosity, &components[0], &components[1], &components[2]);
        // Defer to the OpenGL view to set the brush color
    [paintingView setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
    
    paintingView.image = image;
    
    [drawingsView removeFromSuperview];
    [drawingsView release];
    drawingsView = nil;
    
    [self addSubview:paintingView];
    
}
@end