#import "DocumentManaged.h"
#import "DataSource.h"

@implementation DocumentManaged
@synthesize document;

-(Document *) document
{
    return nil;
}
- (AttachmentManaged*)firstAttachment
{
    NSArray *attachments = self.attachmentsOrdered;
    
    if ([attachments count])
        return [attachments objectAtIndex:0];
    else
        return nil;
}
@end
