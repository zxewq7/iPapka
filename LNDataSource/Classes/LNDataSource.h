//
//  LNDataSource.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Document, ASINetworkQueue;
@interface LNDataSource : NSObject
{
    NSMutableDictionary *_documents;
    ASINetworkQueue     *_networkQueue;
    NSString            *_docDirectory;
    NSString            *documentsListRefreshError;
    NSString            *databaseReplicaId;
    NSString            *viewReplicaId;
    NSString            *host;
}
+ (LNDataSource *)sharedLNDataSource;
@property (nonatomic, retain) NSString            *documentsListRefreshError;
@property (nonatomic, retain) NSMutableDictionary *documents;
@property (nonatomic, retain) NSString            *databaseReplicaId;
@property (nonatomic, retain) NSString            *viewReplicaId;
@property (nonatomic, retain) NSString            *host;
-(void) refreshDocuments;
@end
