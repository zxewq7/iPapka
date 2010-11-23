#import "_DocumentRoot.h"

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

typedef enum _DocumentPriority 
{
    DocumentPriorityNormal = 0,
	DocumentPriorityHigh = 1
} DocumentPriority;


@class Attachment;

@interface DocumentRoot : _DocumentRoot 

@end
