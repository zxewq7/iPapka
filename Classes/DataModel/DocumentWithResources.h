#import "_DocumentWithResources.h"

@interface DocumentWithResources : _DocumentWithResources

@property (readonly) NSMutableArray* linksOrdered;
@property (nonatomic, readonly) Attachment *firstAttachment;
@property (readonly) NSMutableArray* attachmentsOrdered;
@end
