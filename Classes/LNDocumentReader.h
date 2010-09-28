//
//  LNDataSource.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DocumentManaged, ResolutionManaged, SignatureManaged, PageManaged, AttachmentManaged, ASINetworkQueue, LNDocumentReader;

@protocol LNDocumentReaderDataSource
- (DocumentManaged *) documentReader:(LNDocumentReader *) documentReader documentWithUid:(NSString *) uid;
- (ResolutionManaged *) documentReaderCreateResolution:(LNDocumentReader *) documentReader;
- (SignatureManaged *) documentReaderCreateSignature:(LNDocumentReader *) documentReader;
- (DocumentManaged *) documentReaderCreateDocument:(LNDocumentReader *) documentReader;
- (AttachmentManaged *) documentReaderCreateAttachment:(LNDocumentReader *) documentReader;
- (PageManaged *) documentReaderCreatePage:(LNDocumentReader *) documentReader;
- (NSArray *) documentReaderRootUids:(LNDocumentReader *) documentReader;
- (void) documentReader:(LNDocumentReader *) documentReader removeObject:(NSObject *) object;
- (void) documentReaderCommit:(LNDocumentReader *) documentReader;
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
}
- (id) initWithUrl:(NSString *) url andViews:(NSArray *) views;
@property (nonatomic, readonly)         BOOL                  isSyncing;
@property (nonatomic, retain) NSString                        *login;
@property (nonatomic, retain) NSString                        *password;
@property (nonatomic, retain) NSObject<LNDocumentReaderDataSource> *dataSource;
- (void) refreshDocuments;
- (void) purgeCache;
@end
