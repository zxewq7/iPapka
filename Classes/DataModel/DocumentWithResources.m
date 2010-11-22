#import "DocumentWithResources.h"

@implementation DocumentWithResources

- (NSMutableArray*) linksOrdered
{
    return [self mutableOrderedValueForKey:@"links"];
}
@end
