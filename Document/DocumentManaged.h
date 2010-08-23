#import "_DocumentManaged.h"

@class Document;
@interface DocumentManaged : _DocumentManaged {}
@property (nonatomic, readonly, getter=document) Document *document;
@end
