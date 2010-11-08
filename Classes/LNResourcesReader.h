//
//  LNResourcesReader.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 08.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNNetwork.h"
#import <CoreData/NSFetchedResultsController.h>

@interface LNResourcesReader : LNNetwork 
{
    NSFetchedResultsController *unsyncedFiles;
    NSFetchedResultsController *unsyncedPages;
}

@property (nonatomic, retain) NSFetchedResultsController *unsyncedFiles;
@property (nonatomic, retain) NSFetchedResultsController *unsyncedPages;

-(void) sync;
@end
