#import "PersonManaged.h"

@implementation PersonManaged
@synthesize fullName;

-(NSString *) fullName
{
    if (!fullName)
        fullName = [[NSString stringWithFormat:@"%@ %@ %@", self.first, self.middle, self.last] retain];
    return fullName;
}

- (void)dealloc 
{
    [fullName release];
    fullName = nil;
    
    [super dealloc];
}
@end
