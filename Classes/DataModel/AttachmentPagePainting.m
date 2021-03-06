#import "AttachmentPagePainting.h"
#import "AttachmentPage.h"

@implementation AttachmentPagePainting

- (UIImage *) image
{
    NSString *path = self.path;
    
    NSFileManager *df = [NSFileManager defaultManager];
    if (![df fileExistsAtPath: path])
        return nil;
    
    return [UIImage imageWithContentsOfFile:path];
}

-(BOOL) hasPainting
{
    NSFileManager *df = [NSFileManager defaultManager];
    return [df fileExistsAtPath: self.path];
}

-(BOOL) isEditable
{
    return self.page.isEditable;
}
@end
