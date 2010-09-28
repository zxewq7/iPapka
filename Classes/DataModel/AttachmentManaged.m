#import "AttachmentManaged.h"
#import "DocumentManaged.h"

@implementation AttachmentManaged

-(NSString *)path
{
    return [self.document.path stringByAppendingPathComponent:@"attachments"];
}

@end
