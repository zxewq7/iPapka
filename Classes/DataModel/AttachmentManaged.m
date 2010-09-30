#import "AttachmentManaged.h"
#import "Document.h"

@implementation AttachmentManaged

-(NSString *)path
{
    return [self.document.path stringByAppendingPathComponent:@"attachments"];
}

@end
