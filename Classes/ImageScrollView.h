#import <UIKit/UIKit.h>

@class PaintingView;

@interface ImageScrollView : UIScrollView <UIScrollViewDelegate> {
    PaintingView        *paintingView;
    UIImageView         *imageView;
    UIImageView         *drawingsView;
    BOOL                isCommenting;
    CGSize              imageOriginalSize;
    NSRange             *minScaleRanges;
    CGFloat             currentAngle;
}
@property (nonatomic, retain, getter=drawings, setter=setDrawings:) UIImage *drawings;
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
