//
//  LNDataSource.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Document, Resolution, Signature, PageManaged, Attachment, ASINetworkQueue, LNDocumentReader, NSManagedObject, Person;

@protocol LNDocumentReaderDataSource
- (Document *) documentReader:(LNDocumentReader *) documentReader documentWithUid:(NSString *) uid;
- (Person *) documentReader:(LNDocumentReader *) documentReader personWithUid:(NSString *) uid;

- (Resolution *) documentReaderCreateResolution:(LNDocumentReader *) documentReader;
- (Signature *) documentReaderCreateSignature:(LNDocumentReader *) documentReader;
- (Document *) documentReaderCreateDocument:(LNDocumentReader *) documentReader;
- (Attachment *) documentReaderCreateAttachment:(LNDocumentReader *) documentReader;
- (PageManaged *) documentReaderCreatePage:(LNDocumentReader *) documentReader;

- (NSSet *) documentReaderRootUids:(LNDocumentReader *) documentReader;

- (void) documentReader:(LNDocumentReader *) documentReader removeObject:(NSManagedObject *) object;

- (void) documentReaderCommit:(LNDocumentReader *) documentReader;

- (NSArray *) documentReaderUnfetchedResources:(LNDocumentReader *) documentReader;
@end


@interface LNDocumentReader : NSObject
{
    ASINetworkQueue                 *_networkQueue;
    NSString                        *_databaseDirectory;
    NSString                        *login;
    NSString                        *password;
    NSDateFormatter                 *parseFormatterDst;
    NSDateFormatter                 *parseFormatterSimple;
    BOOL                            isSyncing;
    
    NSArray                         *viewUrls;
    NSString                        *urlFetchDocumentFormat;
    NSString                        *urlAttachmentFetchPageFormat;
    NSString                        *urlLinkAttachmentFetchPageFormat;
    
    NSObject<LNDocumentReaderDataSource> *dataSource;
    NSMutableSet                    *uidsToFetch;
    NSMutableSet                    *fetchedUids;
    
    NSUInteger                      viewsLeftToFetch;
    NSUInteger                      documentsLeftToFetch;
}
- (id) initWithUrl:(NSString *) url andViews:(NSArray *) views;
@property (nonatomic, readonly)         BOOL                  isSyncing;
@property (nonatomic, retain) NSString                        *login;
@property (nonatomic, retain) NSString                        *password;
@property (nonatomic, retain) NSObject<LNDocumentReaderDataSource> *dataSource;
- (void) refreshDocuments;
- (void) purgeCache;
@end
