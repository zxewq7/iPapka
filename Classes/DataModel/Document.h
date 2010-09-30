#import "_Document.h"

typedef enum _DocumentStatus {
	DocumentStatusDraft = 0,
    DocumentStatusAccepted = 1,
    DocumentStatusDeclined = 2
} DocumentStatus;

typedef enum _SyncStatus {
	SyncStatusSynced = 0,
    SyncStatusNeedSyncToServer = 1,
    SyncStatusNeedSyncFromServer = 2,
} SyncStatus;

@class Document, AttachmentManaged;

@interface Document : _Document 
@property (nonatomic, readonly, getter=document) Document *document;
@property (nonatomic, readonly) AttachmentManaged *firstAttachment;
@end
