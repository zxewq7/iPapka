#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

//CONSTANTS:

#define kBrushOpacity		(1.0 / 6.0)
#define kBrushPixelStep		3
#define kBrushScale			2
#define kLuminosity			0.75
#define kSaturation			1.0

//CLASS INTERFACES:

typedef enum
{
    kToolTypeNone = 0,
    kToolTypePen = 1,
    kToolTypeMarker = 2,
    kToolTypeEraser = 3,
    kToolTypeStamper = 4
} ToolType;

@class PaintingView, IntRow;
@protocol PaintingViewDelegate <NSObject>

-(void) stampAdded:(PaintingView *) sender index:(NSUInteger) anIndex;
-(void) stampTouched:(PaintingView *) sender index:(NSUInteger) anIndex;

@end

@interface PaintingView : UIView<UIGestureRecognizerDelegate>
{
@private
	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
	
	// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
	GLuint depthRenderbuffer;
	
	GLuint	markerTexture;
    GLuint	penTexture;
    GLuint	eraserTexture;
    GLuint  stamperTexture;
	CGPoint	location;
	CGPoint	previousLocation;
	Boolean	firstTouch;
	Boolean needsErase;
    UIColor *color;
    UIImage *savedContent;
    BOOL    modifiedContentSaved;
    CGFloat markerWidth;
    CGFloat penWidth;
    CGFloat eraserWidth;
    CGFloat stamperWidth;
    ToolType currentTool;
    UITapGestureRecognizer *tapRecognizer;
    NSMutableArray *stamps;
    id<PaintingViewDelegate> paintingDelegate;
    IntRow *numberOfPoints;
    CGFloat minPenScale;
    CGFloat maxPenScale;
    CGFloat penScale;
    BOOL isModified;
	
	// ------------------------------
	// smoothing
	BOOL smEnableSmoothing;
	NSMutableArray *smPoints;
	NSUInteger smCurrentBeginPointIndex;
	GLfloat *smVertexBuffer;
	// ------------------------------
}

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;
@property(nonatomic, readwrite, retain) UIColor *color;

@property(nonatomic, retain, readwrite, getter=image, setter=setImage:) UIImage *image;
@property(nonatomic, retain, readwrite) NSMutableArray *stamps;
@property(nonatomic, retain, readwrite) id<PaintingViewDelegate> paintingDelegate;

@property(readonly) BOOL isModified;
- (void) erase;
- (void) saveContent;
- (void) enableMarker:(BOOL) enabled;
- (void) enablePen:(BOOL) enabled;
- (void) enableEraser:(BOOL) enabled;
- (void) enableStamper:(BOOL) enabled;

@end

