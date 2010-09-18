#import "PersonManaged.h"

@implementation PersonManaged
@synthesize fullName;

-(NSString *) fullName
{
    if (!fullName)
        fullName = [[NSString stringWithFormat:@"%@ %@. %@.", self.last, [self.first substringToIndex: 1], [self.middle substringToIndex: 1]] retain];
    return fullName;
}

- (void)dealloc 
{
    [fullName release];
    fullName = nil;
    
    [super dealloc];
}
@end
