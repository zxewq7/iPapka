#import "Attachment.h"
#import "Document.h"

@implementation Attachment

-(NSString *)path
{
    return [[self.document.path stringByAppendingPathComponent:@"attachments"] stringByAppendingPathComponent: self.uid];
}

- (NSMutableArray*) pagesOrdered
{
    return [self mutableOrderedValueForKey:@"pages"];
}
@end
