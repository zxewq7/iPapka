#import "DocumentWithResources.h"

@implementation DocumentWithResources

- (NSMutableArray*) linksOrdered
{
    return [self mutableOrderedValueForKey:@"links"];
}

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
