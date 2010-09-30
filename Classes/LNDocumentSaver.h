//
//  LNDocumentSaver.h
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 22.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSFetchedResultsController.h>

@class ASINetworkQueue, LNDocumentSaver;

@interface LNDocumentSaver : NSObject<NSFetchedResultsControllerDelegate> 
{
    ASINetworkQueue *queue;
    NSString        *url;
    NSString        *login;
    NSString        *password;
    NSDateFormatter *parseFormatterSimple;
    NSString        *requestUrl;
}

- (id) initWithUrl:(NSString *) anUrl;

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSFetchedResultsController *unsyncedDocuments;
@property (nonatomic, assign, readonly) BOOL isSyncing;

- (void) sync;
@end
