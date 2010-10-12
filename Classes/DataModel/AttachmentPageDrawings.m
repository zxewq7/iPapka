#import "AttachmentPageDrawings.h"

@implementation AttachmentPageDrawings

- (UIImage *) image
{
    NSString *path = self.path;
    
    NSFileManager *df = [NSFileManager defaultManager];
    if (![df fileExistsAtPath: path])
        return nil;
    
    return [UIImage imageWithContentsOfFile:path];
}

@end
