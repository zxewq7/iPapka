#import "Attachment.h"
#import "DocumentWithResources.h"

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
