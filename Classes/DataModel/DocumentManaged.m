#import "DocumentManaged.h"
#import "DataSource.h"

@implementation DocumentManaged
@synthesize document;

-(Document *) document
{
    return nil;
}

-(NSArray *)attachmentsOrdered
{
    return [self valueForKey:@"attachmentsOrdered"];
}
@end
