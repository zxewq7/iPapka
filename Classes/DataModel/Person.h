#import "_Person.h"

@interface Person : _Person
{
    NSString *fullName;
}
@property (nonatomic, retain, readonly) NSString *fullName;
@end
