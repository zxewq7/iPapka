#import "_PersonManaged.h"

@interface PersonManaged : _PersonManaged 
{
    NSString *fullName;
}
@property (nonatomic, retain, readonly) NSString *fullName;
@end
