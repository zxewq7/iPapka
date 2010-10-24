#import "DocumentResolution.h"

@implementation DocumentResolution
- (NSMutableArray*) performersOrdered
{
    return [self mutableOrderedValueForKey:@"performers"];
}
@end
