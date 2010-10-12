//
//  LNDocumentSaver.h
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 22.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSFetchedResultsController.h>

@class ASINetworkQueue;

@interface LNDocumentWriter : NSObject<NSFetchedResultsControllerDelegate> 
{
    ASINetworkQueue *queue;
    NSString        *url;
    NSDateFormatter *parseFormatterSimple;
    NSString        *postDocumentUrl;
    NSString        *postFileUrl;
    NSString        *postFileField;
    NSFetchedResultsController *unsyncedDocuments;
    NSFetchedResultsController *unsyncedFiles;
    BOOL             allRequestsSent;
}

- (id) initWithUrl:(NSString *) anUrl;

@property (nonatomic, retain) NSFetchedResultsController *unsyncedDocuments;
@property (nonatomic, retain) NSFetchedResultsController *unsyncedFiles;
@property (nonatomic, assign, readonly) BOOL isSyncing;

- (void) sync;
@end
