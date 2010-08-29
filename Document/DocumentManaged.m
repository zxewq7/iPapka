#import "DocumentManaged.h"
#import "DataSource.h"

@implementation DocumentManaged
@synthesize document;

-(Document *) document
{
    if (!document)
    {
        document = [[DataSource sharedDataSource] loadDocument:self];
        [document retain];
    }
    return document;
}

-(void) saveDocument
{
    [[DataSource sharedDataSource] saveDocument: self.document];
}

-(void) dealloc
{
    [document release];
    [super dealloc];
}
@end
