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

- (NSMutableArray*) linksOrdered
{
    return [self mutableOrderedValueForKey:@"links"];
}

-(BOOL) isEditable
{
    return (self.statusValue == DocumentStatusDraft || self.statusValue == DocumentStatusNew);
}
@end
