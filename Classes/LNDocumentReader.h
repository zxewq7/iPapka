//
//  LNDataSource.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNNetwork.h"

@class RootDocument, DocumentResolution, DocumentSignature, AttachmentPage, Attachment, ASINetworkQueue, LNDocumentReader, NSManagedObject, Person, CommentAudio, Comment, AttachmentPagePainting;

@protocol LNDocumentReaderDataSource<NSObject>
- (RootDocument *) documentReader:(LNDocumentReader *) documentReader documentWithUid:(NSString *) uid;

- (Person *) documentReader:(LNDocumentReader *) documentReader personWithUid:(NSString *) uid;

- (id) documentReader:(LNDocumentReader *) documentReader createEntity:(Class) entityClass;

- (NSSet *) documentReaderRootUids:(LNDocumentReader *) documentReader;

- (void) documentReader:(LNDocumentReader *) documentReader removeObject:(NSManagedObject *) object;

- (void) documentReaderCommit:(LNDocumentReader *) documentReader;
@end


@interface LNDocumentReader : LNNetwork
{
    NSString                        *_databaseDirectory;
    NSDateFormatter                 *parseFormatterDst;
    NSDateFormatter                 *parseFormatterSimple;
    
    NSArray                         *viewUrls;
    NSString                        *urlFetchDocumentFormat;
    
    id<LNDocumentReaderDataSource> dataSource;
    NSMutableSet                    *uidsToFetch;
    NSMutableSet                    *fetchedUids;
    
    NSUInteger                      viewsLeftToFetch;
    NSUInteger                      documentsLeftToFetch;
    
    NSDictionary                    *statusDictionary;
    
    NSNumberFormatter               *numberFormatter;
    
    NSArray                         *views;
}
@property (nonatomic, retain) id<LNDocumentReaderDataSource>  dataSource;
@property (nonatomic, retain) NSArray*  views;
- (void) purgeCache;
@end
