#import "Document.h"
#import "DataSource.h"

@implementation Document
- (Attachment*)firstAttachment
{
    NSArray *attachments = self.attachmentsOrdered;
    
    if ([attachments count])
        return [attachments objectAtIndex:0];
    else
        return nil;
}

- (NSMutableArray*) attachmentsOrdered
{
    return [self mutableOrderedValueForKey:@"attachments"];
}
@end