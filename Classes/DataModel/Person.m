#import "Person.h"

@implementation Person
@synthesize fullName;

-(NSString *) fullName
{
    if (!fullName)
    {
        NSString *m = self.middle;
        if (m && ![m isEqualToString:@""])
            fullName = [[NSString stringWithFormat:@"%@ %@. %@.", self.last, [self.first substringToIndex: 1], [m substringToIndex: 1]] retain];
        else
            fullName = [[NSString stringWithFormat:@"%@ %@.", self.last, [self.first substringToIndex: 1]] retain];
    }
        
    return fullName;
}

- (void)dealloc 
{
    [fullName release];
    fullName = nil;
    
    [super dealloc];
}
@end
