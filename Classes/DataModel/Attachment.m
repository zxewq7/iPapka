#import "Attachment.h"
#import "Document.h"

@implementation Attachment

-(NSString *)path
{
    return [self.document.path stringByAppendingPathComponent:@"attachments"];
}

@end
