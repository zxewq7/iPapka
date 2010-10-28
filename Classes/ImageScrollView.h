#import <UIKit/UIKit.h>
#import "PaintingView.h"

@interface ImageScrollView : UIScrollView <UIScrollViewDelegate> {
    PaintingView        *paintingView;
    UIImageView         *imageView;
    UIImageView         *savedPaintingView;
    BOOL                isCommenting;
    CGSize              imageOriginalSize;
    CGFloat             currentAngle;
    id<PaintingViewDelegate> paintingDelegate;
    UIColor             *color;
}
@property (nonatomic, retain) UIImage *painting;
@property (readonly)          BOOL isModified;
@property (nonatomic, retain) id<PaintingViewDelegate> paintingDelegate;
@property (nonatomic, retain) UIColor *color;

- (void)displayImage:(UIImage *)image angle:(CGFloat) anAngle;
- (void)setMaxMinZoomScalesForCurrentBounds;

- (CGPoint) pointToCenterAfterRotation;
- (CGFloat) scaleToRestoreAfterRotation;
- (void) restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;
- (void) setCommenting:(BOOL) state;
- (void) rotate:(CGFloat) radiansAngle;
- (void) enableMarker:(BOOL) enabled;
- (void) enablePen:(BOOL) enabled;
- (void) enableEraser:(BOOL) enabled;
- (void) enableStamper:(BOOL) enabled;
@end
