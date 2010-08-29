#import "_DocumentManaged.h"

@class Document;

@interface DocumentManaged : _DocumentManaged 
{
    Document *document;
}

@property (nonatomic, readonly, getter=document) Document *document;
-(void) saveDocument;
@end
