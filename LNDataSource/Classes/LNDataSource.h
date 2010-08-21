//
//  LNDataSource.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Document, ASINetworkQueue;

@protocol LNDataSourceDelegate
- (void) documentUpdated:(Document *) document;
- (void) documentsDeleted:(NSArray *) documents;
- (void) documentAdded:(Document *) document;
- (void) documentsListDidRefreshed:(id) sender;
- (void) documentsListWillRefreshed:(id) sender;
@end


@interface LNDataSource : NSObject
{
    NSMutableSet                    *cacheIndex;
    ASINetworkQueue                 *_networkQueue;
    NSString                        *_databaseDirectory;
    NSString                        *databaseReplicaId;
    NSString                        *viewReplicaId;
    NSString                        *host;
    NSObject<LNDataSourceDelegate>  *delegate;
}
@property (nonatomic, retain) NSString                        *databaseReplicaId;
@property (nonatomic, retain) NSString                        *viewReplicaId;
@property (nonatomic, retain) NSString                        *host;
@property (nonatomic, retain) NSObject<LNDataSourceDelegate>  *delegate;
- (void) refreshDocuments;
- (void) loadCache;
- (Document *) loadDocument:(NSString *) anUid;
- (void)deleteDocument:(NSString *) anUid;
@end
