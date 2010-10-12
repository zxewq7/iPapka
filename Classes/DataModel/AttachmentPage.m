#import "AttachmentPage.h"
#import "Attachment.h"

@implementation AttachmentPage

-(NSString *)path
{
    return [[self.attachment.path stringByAppendingPathComponent:@"pages"] stringByAppendingPathComponent: [NSString stringWithFormat:@"%d", [self.number intValue]]];
}

-(NSString *)pathImage
{
    return [self.path stringByAppendingPathComponent: @"image.png"];
}

-(UIImage *) image
{
    NSString *path = self.pathImage;
    
    NSFileManager *df = [NSFileManager defaultManager];
    if (![df fileExistsAtPath: path])
        return nil;
    
    return [UIImage imageWithContentsOfFile:path];
}
@end
