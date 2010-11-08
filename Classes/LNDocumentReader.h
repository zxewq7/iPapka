//
//  LNDataSource.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Document, DocumentResolution, DocumentSignature, AttachmentPage, Attachment, ASINetworkQueue, LNDocumentReader, NSManagedObject, Person, CommentAudio, Comment, AttachmentPagePainting;

@protocol LNDocumentReaderDataSource<NSObject>
- (Document *) documentReader:(LNDocumentReader *) documentReader documentWithUid:(NSString *) uid;
- (Person *) documentReader:(LNDocumentReader *) documentReader personWithUid:(NSString *) uid;

- (id) documentReader:(LNDocumentReader *) documentReader createEntity:(Class) entityClass;

- (NSSet *) documentReaderRootUids:(LNDocumentReader *) documentReader;

- (void) documentReader:(LNDocumentReader *) documentReader removeObject:(NSManagedObject *) object;

- (void) documentReaderCommit:(LNDocumentReader *) documentReader;

- (NSArray *) documentReaderUnfetchedPages:(LNDocumentReader *) documentReader;

- (NSArray *) documentReaderUnfetchedFiles:(LNDocumentReader *) documentReader;
@end


@interface LNDocumentReader : NSObject
{
    ASINetworkQueue                 *_networkQueue;
    NSString                        *_databaseDirectory;
    NSDateFormatter                 *parseFormatterDst;
    NSDateFormatter                 *parseFormatterSimple;
    BOOL                            isSyncing;
    
    NSArray                         *viewUrls;
    NSString                        *urlFetchDocumentFormat;
    NSString                        *urlAttachmentFetchPageFormat;
    NSString                        *urlLinkAttachmentFetchPageFormat;
    
    id<LNDocumentReaderDataSource> dataSource;
    NSMutableSet                    *uidsToFetch;
    NSMutableSet                    *fetchedUids;
    
    NSUInteger                      viewsLeftToFetch;
    NSUInteger                      documentsLeftToFetch;
    
    NSDictionary                    *statusDictionary;
    
    BOOL                            hasErrors;
    BOOL                            allRequestsSent;
    
    NSString                        *baseUrl;
    
    NSNumberFormatter               *numberFormatter;
}
- (id) initWithUrl:(NSString *) url andViews:(NSArray *) views;
@property (nonatomic, readonly)         BOOL                  isSyncing;
@property (nonatomic, readonly)         BOOL                  hasErrors;
@property (nonatomic, readonly)         BOOL                  allRequestsSent;
@property (nonatomic, retain) id<LNDocumentReaderDataSource>  dataSource;
- (void) sync;
- (void) purgeCache;
@end
