#import "PageManaged.h"
#import "AttachmentManaged.h"

@implementation PageManaged

-(NSString *)path
{
    return [self.attachment.path stringByAppendingPathComponent:@"pages"];
}

@end
