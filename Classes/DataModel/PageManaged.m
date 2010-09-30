#import "PageManaged.h"
#import "AttachmentManaged.h"

@implementation PageManaged

-(NSString *)path
{
    return [self.attachment.path stringByAppendingPathComponent:@"pages"];
}

-(NSString *)pathImage
{
    return [self.path stringByAppendingPathComponent: [NSString stringWithFormat:@"%d", [self.number intValue]]];
}

-(NSString *)pathDrawings
{
    return [self.pathImage stringByAppendingPathExtension:@"drawings"];
}

- (UIImage *) drawings
{
    NSString *path = self.pathDrawings;
    
    NSFileManager *df = [NSFileManager defaultManager];
    if (![df fileExistsAtPath: path])
        return nil;
    
    return [UIImage imageWithContentsOfFile:path];
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
