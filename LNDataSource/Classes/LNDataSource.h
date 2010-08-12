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
    NSArray             *_documents;
    ASINetworkQueue     *_networkQueue;
    NSString            *_docDirectory;
    NSMutableDictionary *_handlers;
    BOOL                documentsListRefreshed;
    NSString            *documentsListRefreshError;
}
+ (LNDataSource *)sharedLNDataSource;
@property (nonatomic)         BOOL     documentsListRefreshed;
@property (nonatomic, retain) NSString *documentsListRefreshError;
-(NSUInteger) count;
-(Document *) documentAtIndex:(NSUInteger) anIndex;
-(void) refreshDocuments;
@end
