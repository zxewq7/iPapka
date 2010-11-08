//
//  LNDocumentSaver.h
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 22.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSFetchedResultsController.h>
#import "LNNetwork.h"

@class ASINetworkQueue;

@interface LNDocumentWriter : LNNetwork<NSFetchedResultsControllerDelegate> 
{
    NSDateFormatter *parseFormatterSimple;
    NSString        *postFileUrl;
    NSString        *postFileField;
    NSFetchedResultsController *unsyncedDocuments;
    NSFetchedResultsController *unsyncedFiles;
}

@property (nonatomic, retain) NSFetchedResultsController *unsyncedDocuments;
@property (nonatomic, retain) NSFetchedResultsController *unsyncedFiles;
@end
