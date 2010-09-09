#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

//CONSTANTS:

#define kBrushOpacity		(1.0 / 3.0)
#define kBrushPixelStep		3
#define kBrushScale			2
#define kLuminosity			0.75
#define kSaturation			1.0

//CLASS INTERFACES:

typedef enum
{
    kToolTypeNone = 0,
    kToolTypeMarker = 1,
    kToolTypeEraser = 2,
    kToolTypeStamper = 3
} ToolType;

@class PaintingView;
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
    GLuint	eraserTexture;
    GLuint  stamperTexture;
	CGPoint	location;
	CGPoint	previousLocation;
	Boolean	firstTouch;
	Boolean needsErase;
    UIColor *currentColor;
    UIImage *savedContent;
    BOOL    modifiedContentSaved;
    CGFloat markerWidth;
    CGFloat eraserWidth;
    CGFloat stamperWidth;
    ToolType currentTool;
    UITapGestureRecognizer *tapRecognizer;
    NSMutableArray *stamps;
    id<PaintingViewDelegate> paintingDelegate;
}

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;

@property(nonatomic, retain, readwrite, getter=image, setter=setImage:) UIImage *image;
@property(nonatomic, retain, readwrite) NSMutableArray *stamps;
@property(nonatomic, retain, readwrite) id<PaintingViewDelegate> paintingDelegate;
- (void) erase;
- (void) setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
- (void) saveContent;
- (void) enableMarker:(BOOL) enabled;
- (void) enableEraser:(BOOL) enabled;
- (void) enableStamper:(BOOL) enabled;
@end
