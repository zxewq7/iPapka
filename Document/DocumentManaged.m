#import "DocumentManaged.h"
#import "DataSource.h"

@implementation DocumentManaged
@synthesize document;

-(Document *) document
{
    return [[DataSource sharedDataSource] loadDocument:self];
}

@end
