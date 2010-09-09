#import <UIKit/UIKit.h>
#import "PaintingView.h"

@interface ImageScrollView : UIScrollView <UIScrollViewDelegate> {
    PaintingView        *paintingView;
    UIImageView         *imageView;
    UIImageView         *drawingsView;
    BOOL                isCommenting;
    CGSize              imageOriginalSize;
    NSRange             *minScaleRanges;
    CGFloat             currentAngle;
    id<PaintingViewDelegate> paintingDelegate;
}
@property (nonatomic, retain, getter=drawings, setter=setDrawings:) UIImage *drawings;
@property(nonatomic, retain, getter=paintingDelegate, setter=setPaintingDelegate:) id<PaintingViewDelegate> paintingDelegate;

- (void)displayImage:(UIImage *)image angle:(CGFloat) anAngle;
- (void)setMaxMinZoomScalesForCurrentBounds;

- (CGPoint) pointToCenterAfterRotation;
- (CGFloat) scaleToRestoreAfterRotation;
- (void) restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;
- (void) setCommenting:(BOOL) state;
- (void) rotate:(CGFloat) radiansAngle;
- (void) enableMarker:(BOOL) enabled;
- (void) enableEraser:(BOOL) enabled;
- (void) enableStamper:(BOOL) enabled;
@end
