#import "_Document.h"

typedef enum _DocumentStatus {
    DocumentStatusDraft = 0,
	DocumentStatusNew = 1,
    DocumentStatusAccepted = 3,
    DocumentStatusDeclined = 4
} DocumentStatus;

typedef enum _SyncStatus {
	SyncStatusSynced = 0,
    SyncStatusNeedSyncToServer = 1,
    SyncStatusNeedSyncFromServer = 2,
} SyncStatus;

@class Document, Attachment;

@interface Document : _Document 
@property (nonatomic, readonly, getter=document) Document *document;
@property (nonatomic, readonly) Attachment *firstAttachment;
@end
