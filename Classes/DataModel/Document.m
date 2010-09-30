#import "Document.h"
#import "DataSource.h"

@implementation Document
@synthesize document;

-(Document *) document
{
    return nil;
}
- (Attachment*)firstAttachment
{
    NSArray *attachments = self.attachmentsOrdered;
    
    if ([attachments count])
        return [attachments objectAtIndex:0];
    else
        return nil;
}
@end
