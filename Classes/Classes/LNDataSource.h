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
    NSString                        *url;
    NSString                        *viewId;
    NSString                        *login;
    NSString                        *password;
    NSObject<LNDataSourceDelegate>  *delegate;
    NSDateFormatter                 *parseFormatterDst;
    NSDateFormatter                 *parseFormatterSimple;
    BOOL                            isSyncing;
    NSString                        *dataSourceId;
    
    NSString                        *urlFetchView;
    NSString                        *urlFetchDocumentFormat;
    NSString                        *urlAttachmentFetchPageFormat;
    NSString                        *urlLinkAttachmentFetchPageFormat;
}
@property (nonatomic, retain, readonly) NSString              *url;
@property (nonatomic, retain, readonly) NSString              *viewId;
@property (nonatomic, retain, readonly) NSString              *dataSourceId;
@property (nonatomic, retain) NSString                        *login;
@property (nonatomic, retain) NSString                        *password;
@property (nonatomic, retain) NSObject<LNDataSourceDelegate>  *delegate;
- (void) refreshDocuments;
- (void) loadCache;
- (Document *) loadDocument:(NSString *) anUid;
- (void) deleteDocument:(NSString *) anUid;
- (void) purgeCache;
- (void) saveDocument:(Document *) document;
- (id) initWithId:(NSString *) aDataSourceId viewId:(NSString *) aViewId andUrl:(NSString*) anUrl;
- (void) moveDocument:(NSString *) documentUid destination:(LNDataSource *) destination;
- (void) addDocument:(NSString *) uid path:(NSString *) path moveSource:(BOOL) moveSource;
@end
