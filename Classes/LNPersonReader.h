//
//  LNPersonReader.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 13.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue, LNPersonReader, Person, NSManagedObject;

@protocol LNPersonReaderDataSource<NSObject>
- (Person *) personReader:(LNPersonReader *) personReader personWithUid:(NSString *) uid;
- (Person *) personReaderCreatePerson:(LNPersonReader *) personReader;
- (NSSet *) personReaderAllPersonsUids:(LNPersonReader *) personReader;
- (void) personReader:(LNPersonReader *) personReader removeObject:(NSManagedObject *) object;
- (void) personReaderCommit:(LNPersonReader *) personReader;
@end


@interface LNPersonReader : NSObject 
{
    ASINetworkQueue *queue;
    NSString        *url;
    id<LNPersonReaderDataSource> dataSource;
    BOOL isSyncing;
    BOOL allRequestsSent;
}

- (id) initWithUrl:(NSString *) anUrl;

@property (nonatomic, assign, readonly) BOOL isSyncing;
@property (nonatomic, retain) id<LNPersonReaderDataSource> dataSource;

- (void) sync;
@end
