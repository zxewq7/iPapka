#import "_AttachmentPage.h"

@interface AttachmentPage : _AttachmentPage
@property (readonly) NSString *path;
@property (readonly) NSString *pathImage;
@property (readonly) UIImage  *image;
@property (readonly) BOOL  hasPaintings;
@property (readonly) BOOL  hasAudio;
@property (readonly) BOOL  hasText;
@end
