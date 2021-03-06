#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "PaintingView.h"
#import "UIColor-Expanded.h"
#import "Texture2D.h"
#import "IntRow.h"

    //CLASS IMPLEMENTATIONS:

    // A class extension to declare private methods
@interface PaintingView (private)
- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end;
- (void) paintTexture:(UIImage *) aTexture;
- (void) createTexture:(GLuint *) texture withImage:(UIImage *) anImage;
- (void) setBrushColor;

// ------------------------------
// smoothing
- (void)drawSmoothSpline;
// ------------------------------
@end

@implementation PaintingView

@synthesize  location;
@synthesize  previousLocation;
@synthesize  image;
@synthesize paintingDelegate;
@synthesize stamps;
@synthesize color;
@synthesize isModified;

-(void)setImage:(UIImage *) aDrawings;
{
    [self erase];
    if (savedContent != aDrawings) 
    {
        [self paintTexture:aDrawings];
        [savedContent release];
        savedContent = [aDrawings retain];
    }
    modifiedContentSaved = YES;
    isModified = NO;
}

- (void) paintTexture:(UIImage *) aTexture
{
    [self erase];
    if (!aTexture)
        return;
        //set color to white
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    
    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    CGRect	bounds = [self bounds];
    
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    
    Texture2D *backgroundTex = [[Texture2D alloc] initWithImage:aTexture];
    
    glDisable(GL_BLEND);
    
    [backgroundTex drawInRect:bounds];
    
    [backgroundTex release];
    
    glEnable(GL_BLEND);
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    switch (currentTool) 
    {
        case kToolTypeEraser:
            [self enableEraser:YES];
            break;
        case kToolTypeMarker:
            [self enableMarker:YES];
            break;
        case kToolTypePen:
            [self enablePen:YES];
            break;
        case kToolTypeStamper:
            [self enableStamper:YES];
            break;
        case kToolTypeNone:
            break;
        default:
            NSAssert1(NO, @"Unknown tool: %d", currentTool);
    }
}

    //http://www.iphonedevsdk.com/forum/iphone-sdk-development/57381-snapshot-problem.html
- (UIImage*)image
{
        // Get the size of the backing CAEAGLLayer
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    
    int bitsPerComponent    = 8;
    int bitsPerPixel        = 32;
    int bytesPerPixel       = (bitsPerComponent * 4)/8;
    int bytesPerRow         = bytesPerPixel * width;
    NSInteger dataLength    = bytesPerRow * height;
    
    NSMutableData *buffer   = [[NSMutableData alloc] initWithCapacity:dataLength];
    
    if( ! buffer ) 
    {
        AZZLog(@"PaintingView#image: not enough memory");
        [buffer release];
        return nil;
    }
    
        // Read pixel data from the framebuffer
    glFinish();
    glPixelStorei(GL_PACK_ALIGNMENT, 4);    /* Force 4-byte
                                             alignment */
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, [buffer mutableBytes]);
    
        // Create a CGImage with the pixel data
        // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
        // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, [buffer mutableBytes], dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
        // OpenGL ES measures data in PIXELS
        // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
        // if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // // so that you get a high-resolution snapshot when its value is greater than 1.0
        // CGFloat scale = eaglview.contentScaleFactor;
        // widthInPoints = width / scale;
        // heightInPoints = height / scale;
        // UIGraphicsBeginImageContextWithOptions(CGSizeMake( widthInPoints, heightInPoints), NO, scale);
        // }
        // else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    widthInPoints = width;
    heightInPoints = height;
    UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
        // }
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
        // UIKit coordinate system is upside down to GL/Quartz coordinate system
        // Flip the CGImage by rendering it to the flipped bitmap context
        // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
        // Retrieve the UIImage from the current context
    UIImage *image1 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
        // Clean up
    [buffer release];
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image1;
}

    // Implement this to override the default layer class (which is [CALayer class]).
    // We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame 
{
	
    if ((self = [super initWithFrame:frame])) {
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = YES;
            // In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if (!context || ![EAGLContext setCurrentContext:context]) {
			[self release];
			return nil;
		}
		
            // Set the view's scale factor
#warning iOS 4 stuff
            //		self.contentScaleFactor = 1.0;
        
            // Setup OpenGL states
		glMatrixMode(GL_PROJECTION);
		CGRect frame = self.bounds;
		CGFloat scale = 1.0;
#warning iOS 4 stuff
            //		CGFloat scale = self.contentScaleFactor;
        
            // Setup the view port in Pixels
		glOrthof(0, frame.size.width * scale, 0, frame.size.height * scale, -1, 1);
		glViewport(0, 0, frame.size.width * scale, frame.size.height * scale);
		glMatrixMode(GL_MODELVIEW);
		
		glDisable(GL_DITHER);
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		
	    glEnable(GL_BLEND);
            // Set a blending function appropriate for premultiplied alpha pixel data
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		
		glEnable(GL_POINT_SPRITE_OES);
		glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
		
            // Make sure to start with a cleared buffer
		needsErase = YES;
        
        stamps = [[NSMutableArray alloc] init];
		
		
		// ------------------------------
		// smoothing
		smEnableSmoothing=TRUE;
		smPoints=nil;
		smVertexBuffer=NULL;
		// ------------------------------
		
	}
	
	return self;
}

    // If our view is resized, we'll be asked to layout subviews.
    // This is the perfect opportunity to also update the framebuffer so that it is
    // the same size as our display area.
-(void)layoutSubviews
{
    [EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	
        // Clear the framebuffer the first time it is allocated
	if (needsErase) {
		[self erase];
		needsErase = NO;
	}
    
    [self paintTexture:savedContent];
}

- (void)saveContent
{
    if (modifiedContentSaved)
        return;
    [savedContent release];
    savedContent = self.image;
    
    [savedContent retain];
    modifiedContentSaved = YES;
}


    // Releases resources when they are not longer needed.
- (void) dealloc
{
	if (markerTexture)
	{
		glDeleteTextures(1, &markerTexture);
		markerTexture = 0;
	}

    if (penTexture)
    {
		glDeleteTextures(1, &penTexture);
		penTexture = 0;
    }
    
    if (eraserTexture)
	{
		glDeleteTextures(1, &eraserTexture);
		eraserTexture = 0;
	}
    
    if (stamperTexture)
	{
		glDeleteTextures(1, &stamperTexture);
		stamperTexture = 0;
	}
    
	if([EAGLContext currentContext] == context)
	{
		[EAGLContext setCurrentContext:nil];
	}
	
    self.stamps = nil;
    self.paintingDelegate = nil;
	[context release];
    self.color = nil;
    [savedContent release];
    [tapRecognizer release];
    [numberOfPoints release];
    
	// ------------------------------
	// smoothing
	[smPoints release];
	if (smVertexBuffer)
	{
		free(smVertexBuffer);
		smVertexBuffer=NULL;
	}
	// ------------------------------
	
	[super dealloc];
}

    // Erases the screen
- (void) erase
{
	[EAGLContext setCurrentContext:context];
	
        // Clear the buffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
        // Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


    // Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (currentTool == kToolTypeStamper) 
        return;

	CGRect				bounds = [self bounds];
    UITouch*	touch = [[event touchesForView:self] anyObject];
	firstTouch = YES;
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
	location = [touch locationInView:self];
	location.y = bounds.size.height - location.y;
	
	// ------------------------------
	// smoothing
	if (smEnableSmoothing && currentTool==kToolTypePen)
	{
		smPoints=[[NSMutableArray alloc] initWithCapacity:100];
		CGPoint p=CGPointMake(location.x,location.y);
		NSValue *q=[[NSValue alloc] initWithBytes:&p objCType:@encode(CGPoint)];
		[smPoints addObject: q];
		[q release];
	}
	// ------------------------------
	
    modifiedContentSaved = NO;
    [numberOfPoints release];
    numberOfPoints = [[IntRow alloc] init];
    numberOfPoints.maxSize = 5;
    isModified = YES;
}

    // Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  
    if (currentTool == kToolTypeStamper) 
        return;
    
	CGRect				bounds = [self bounds];
	UITouch*			touch = [[event touchesForView:self] anyObject];
    
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
	if (firstTouch) {
		firstTouch = NO;
        previousLocation = location;
        location = [touch locationInView:self];
        location.y = bounds.size.height - location.y;
	} else {
		location = [touch locationInView:self];
	    location.y = bounds.size.height - location.y;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
	}

	// ------------------------------
	// smoothing
	static int iii=0;
	static int jjj=0; // 0 - every, 2 - 1, 3, 5...
	if (smEnableSmoothing && currentTool==kToolTypePen)
	{
if (jjj && ++iii>=jjj)
{
	iii=0;
	return;
}
		
		CGPoint p=CGPointMake(location.x,location.y);
		NSValue *q=[[NSValue alloc] initWithBytes:&p objCType:@encode(CGPoint)];
		[smPoints addObject: q];
		[q release];
		NSUInteger q1=[smPoints count];
		if (q1>=4)
		{
			if (q1==4)
				smCurrentBeginPointIndex=0;
			else
				smCurrentBeginPointIndex++;
			[self drawSmoothSpline];

		}
		return;
	}
	// ------------------------------
	
	
	// Render the stroke
	[self renderLineFromPoint:previousLocation toPoint:location];
}

    // Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (currentTool == kToolTypeStamper) 
        return;

	CGRect				bounds = [self bounds];
    UITouch*	touch = [[event touchesForView:self] anyObject];
	if (firstTouch) {
		firstTouch = NO;
		previousLocation = [touch previousLocationInView:self];
		previousLocation.y = bounds.size.height - previousLocation.y;
		[self renderLineFromPoint:previousLocation toPoint:location];
	}

	// ------------------------------
	// smoothing
	if (smEnableSmoothing && currentTool==kToolTypePen)
	{
		if (smPoints)
		{
			[smPoints release];
			smPoints=nil;
		}
	}
	// ------------------------------
	
    [numberOfPoints release];
    numberOfPoints = nil;
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (currentTool != kToolTypeStamper) 
        return NO;
    
    return YES;
}

-(void) handleTapFrom:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self];
    
    CGRect				bounds = [self bounds];
	touchPoint.y = bounds.size.height - touchPoint.y;
    
    NSUInteger stampIndex = NSNotFound;
    NSUInteger count = [stamps count];
    for(NSUInteger i=0;i<count;i++)
    {
        CGRect stampRect = [[stamps objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(stampRect, touchPoint))
        {
            stampIndex = i;
            break;
        }
        
    }
    if(stampIndex == NSNotFound)
    {
        
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        [self setBrushColor];
        [self renderLineFromPoint:CGPointMake(touchPoint.x, touchPoint.y) toPoint: CGPointMake(touchPoint.x, touchPoint.y)];
        [stamps addObject:[NSValue valueWithCGRect:CGRectMake(touchPoint.x, touchPoint.y, stamperWidth, stamperWidth)]];
        if ([paintingDelegate respondsToSelector:@selector(stampAdded:index:)]) 
            [paintingDelegate stampAdded:self index:[stamps count]-1];

    }
    else
    {
        if ([paintingDelegate respondsToSelector:@selector(stampTouched:index:)]) 
            [paintingDelegate stampTouched:self index:stampIndex];
    }    
}
    // Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
        // If appropriate, add code necessary to save the state of the application.
        // This application is not saving state.
}

- (void) setColor:(UIColor *) aColor;
{
    if (color != aColor)
    {
        [color release];
        color = [aColor retain];
    }
    [self setBrushColor];
}

- (void) enablePen:(BOOL) enabled
{
    currentTool = kToolTypePen;

    if (!penTexture)
    {
        UIImage *penImage = [UIImage imageNamed:@"BrushPen.png"];
        penWidth = penImage.size.width;
        [self createTexture:&penTexture withImage:penImage];
        maxPenScale = penWidth / 5.0f;
        minPenScale = 7.0f;
    }

    penScale = maxPenScale;

    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);

    [self setBrushColor];
    
    glBindTexture(GL_TEXTURE_2D, penTexture);
    glPointSize(penWidth / penScale);
}

- (void) enableMarker:(BOOL) enabled
{
    currentTool = kToolTypeMarker;

    if (!markerTexture)
    {
        UIImage *markerImage = [UIImage imageNamed:@"BrushMarker.png"];
        markerWidth = markerImage.size.width;
        [self createTexture:&markerTexture withImage:markerImage];
    }

    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    [self setBrushColor];
    glBindTexture(GL_TEXTURE_2D, markerTexture);
    glPointSize(markerWidth / kBrushScale);
}
- (void) enableEraser:(BOOL) enabled
{
    currentTool = kToolTypeEraser;

    if (!eraserTexture)
    {
        UIImage *eraserImage = [UIImage imageNamed:@"BrushErase.png"];
        eraserWidth = eraserImage.size.width;
        [self createTexture:&eraserTexture withImage:eraserImage];
    }
    glColor4f(0.0, 0.0, 0.0, 0.0);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_DST_ALPHA);
    glDisable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, eraserTexture);
    glPointSize(eraserWidth / kBrushScale);
}
- (void) enableStamper:(BOOL) enabled
{
    if (enabled)
    {
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        [self addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
        
        if (!stamperTexture)
        {
            UIImage *stamperImage = [UIImage imageNamed:@"BrushComment.png"];
            stamperWidth = stamperImage.size.width;
            [self createTexture:&stamperTexture withImage:stamperImage];
        }
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
        [self setBrushColor];
        glBindTexture(GL_TEXTURE_2D, stamperTexture);
        glPointSize(stamperWidth);
        currentTool = kToolTypeStamper;
    }
    else
    {
        [self removeGestureRecognizer: tapRecognizer];
        [tapRecognizer release];
        currentTool = kToolTypeNone;
    }

}
@end

@implementation PaintingView (Private)

    // Drawings a line onscreen based on where the user touches
- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{

	static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0,
    count,
    i;
    
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
    
    if (currentTool == kToolTypePen)
    {
        NSUInteger np = sqrt(pow((start.y - end.y),2) + pow((start.x - end.x),2));
        [numberOfPoints add: np];
        
        double divider = numberOfPoints.median;
        if (divider > maxPenScale)
            divider = maxPenScale;
        else if (divider < minPenScale)
            divider = minPenScale;
        
        glPointSize(penWidth / divider);
    }
    
        // Convert locations from Points to Pixels
#warning iOS 4 stuff
    CGFloat scale = 1.0;
        //	CGFloat scale = self.contentScaleFactor;
	start.x *= scale;
	start.y *= scale;
	end.x *= scale;
	end.y *= scale;
	
        // Allocate vertex array buffer
	if(vertexBuffer == NULL)
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
	
        // Add points to the buffer so there are drawing points every X pixels
	count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
	for(i = 0; i < count; ++i) {
		if(vertexCount == vertexMax) {
			vertexMax = 2 * vertexMax;
			vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
		}
		
		vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
		vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
		vertexCount += 1;
	}
	
        // Render the vertex array
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
	glDrawArrays(GL_POINTS, 0, vertexCount);
	
        // Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (BOOL)createFramebuffer
{
        // Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
        // This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
        // allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
        // For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		AZZLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

    // Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

- (void) createTexture:(GLuint *) texture withImage:(UIImage *) anImage;
{
    CGImageRef		brushImage;
	CGContextRef	brushContext;
	GLubyte			*brushData;
	size_t			width, height;
        // Create a texture from an image
        // First create a UIImage object from the data in a image file, and then extract the Core Graphics image
    brushImage = anImage.CGImage;
    
        // Get the width and height of the image
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    
        // Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
        // you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.
    
        // Make sure the image exists
    if(brushImage) {
            // Allocate  memory needed for the bitmap context
        brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
            // Use  the bitmatp creation function provided by the Core Graphics framework. 
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
            // After you create the context, you can draw the  image to the context.
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
            // You don't need the context at this point, so you need to release it to avoid memory leaks.
        CGContextRelease(brushContext);
            // Use OpenGL ES to generate a name for the texture.
        glGenTextures(1, texture);
            // Bind the texture name. 
        glBindTexture(GL_TEXTURE_2D, *texture);
            // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
            // Release  the image data; it's no longer needed
        free(brushData);
    }
}

- (void)setBrushColor
{
    // Set the brush color using premultiplied alpha values
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
    
    switch (currentTool)
    {
        case kToolTypeMarker: //set color with opacity
            r = color.red   * kBrushOpacity;
            g = color.green * kBrushOpacity;
            b = color.blue  * kBrushOpacity;
            a = kBrushOpacity;
            
            glColor4f(r, g, b, a);
            break;
        case kToolTypeEraser: //do nothing
            break;
        default:
            r = color.red;
            g = color.green;
            b = color.blue;
            a = 1.0f;
            
            glColor4f(r, g, b, a);
            break;
    }
}

// ------------------------------
// smoothing
- (void)drawSmoothSpline
{
	static NSUInteger vertexMax=0;
	
	CGPoint p1=[[smPoints objectAtIndex: smCurrentBeginPointIndex] CGPointValue];
	CGPoint p2=[[smPoints objectAtIndex: smCurrentBeginPointIndex+1] CGPointValue];
	CGPoint p3=[[smPoints objectAtIndex: smCurrentBeginPointIndex+2] CGPointValue];
	CGPoint p4=[[smPoints objectAtIndex: smCurrentBeginPointIndex+3] CGPointValue];
	
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	//	NSUInteger np=sqrt(pow((p3.y-p4.y),2)+pow((p3.x-p4.x),2));
	NSUInteger np=sqrt(pow((p1.y-p4.y),2)+pow((p1.x-p4.x),2));
	[numberOfPoints add: np];
	double divider = numberOfPoints.median;
	if (divider > maxPenScale)
		divider = maxPenScale;
	else if (divider < minPenScale)
		divider = minPenScale;
	glPointSize(penWidth / divider);
    
	// Convert locations from Points to Pixels
#warning iOS 4 stuff
    CGFloat scale = 1.0;
	//	CGFloat scale = self.contentScaleFactor;
	p1.x*=scale;
	p1.y*=scale;
	p2.x*=scale;
	p2.y*=scale;
	p3.x*=scale;
	p3.y*=scale;
	p4.x*=scale;
	p4.y*=scale;
#define DSS_LENGTH(pp1,pp2,dev) (MAX(ceilf(sqrtf((pp2.x-pp1.x)*(pp2.x-pp1.x)+(pp2.y-pp1.y)*(pp2.y-pp1.y))/dev),1))
	NSUInteger count=DSS_LENGTH(p1,p2,kBrushPixelStep)+DSS_LENGTH(p2,p3,kBrushPixelStep)+DSS_LENGTH(p3,p4,kBrushPixelStep);
#undef DSS_LENGTH
//	count=100;
	if (!smVertexBuffer)
		smVertexBuffer=malloc((vertexMax=count)*2*sizeof(GLfloat));
	else if (count>vertexMax)
		smVertexBuffer=realloc(smVertexBuffer,(vertexMax=count)*2*sizeof(GLfloat));

	CGPoint r;
	float countf=(float)count,t,t2,t3;
	for(NSUInteger i=0;i<count;++i)
	{
		{
			t3=(t2=(t=((float)i)/countf)*t)*t;
			r.x=0.5f*(2.0f*p2.x-(p1.x-p3.x)*t+(2.0f*p1.x-5.0f*p2.x+4*p3.x-p4.x)*t2-(p1.x-3.0f*p2.x+3.0f*p3.x-p4.x)*t3);
			r.y=0.5f*(2.0f*p2.y-(p1.y-p3.y)*t+(2.0f*p1.y-5.0f*p2.y+4*p3.y-p4.y)*t2-(p1.y-3.0f*p2.y+3.0f*p3.y-p4.y)*t3);
		};
		smVertexBuffer[2*i+0]=r.x;
		smVertexBuffer[2*i+1]=r.y;
	}
	
	glVertexPointer(2,GL_FLOAT,0,smVertexBuffer);
	glDrawArrays(GL_POINTS,0,count);
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES,viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];	
}
// ------------------------------

@end