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
@end
