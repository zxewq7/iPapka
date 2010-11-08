//
//  LNPersonReader.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 13.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNNetwork.h"

@class LNPersonReader, Person, NSManagedObject;

@protocol LNPersonReaderDataSource<NSObject>
- (Person *) personReader:(LNPersonReader *) personReader personWithUid:(NSString *) uid;
- (Person *) personReaderCreatePerson:(LNPersonReader *) personReader;
- (NSSet *) personReaderAllPersonsUids:(LNPersonReader *) personReader;
- (void) personReader:(LNPersonReader *) personReader removeObject:(NSManagedObject *) object;
- (void) personReaderCommit:(LNPersonReader *) personReader;
@end


@interface LNPersonReader : LNNetwork 
{
    NSString        *url;
    id<LNPersonReaderDataSource> dataSource;
}

@property (nonatomic, retain) id<LNPersonReaderDataSource> dataSource;

- (void) sync;
@end
