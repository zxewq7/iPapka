#import "_PageManaged.h"

@interface PageManaged : _PageManaged
@property (readonly) NSString *path;
@property (readonly) NSString *pathImage;
@property (readonly) NSString *pathDrawings;
@property (readonly) UIImage  *image;
@property (readonly) UIImage  *drawings;
@end
