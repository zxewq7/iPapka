//
//  LNPersonReader.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 13.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNPersonReader.h"
#import "Person.h"

static NSString* kFieldUid = @"id";
static NSString* kFieldFirst = @"first";
static NSString* kFieldLast = @"last";
static NSString* kFieldMiddle = @"middle";

@implementation LNPersonReader
@synthesize dataSource;

- (id) init
{
    if ((self = [super init])) 
    {
        
        url = [self.serverUrl stringByAppendingString:@"/getExecutors?OpenAgent"];
        [url retain];
    }
    return self;
}
- (void) sync;
{
    [self beginSession];
    
    id<LNPersonReaderDataSource> mds = [self dataSource];

    __block LNPersonReader *blockSelf = self;

    [self jsonRequestWithUrl:url andHandler:^(BOOL err, id response)
    {
        if (err)
            return;

        NSMutableSet *allUids = [NSMutableSet setWithCapacity:[response count]];
        
        for (NSDictionary *personDict in response)
        {
            NSString *uid = [personDict objectForKey:kFieldUid];
            NSString *first = [personDict objectForKey:kFieldFirst];
            NSString *last = [personDict objectForKey:kFieldLast];
            NSString *middle = [personDict objectForKey:kFieldMiddle];
            
            if (!(uid && first && last))
            {
                blockSelf.hasError = YES;
                AZZLog(@"not enough person attributes, skipped %@", personDict);
                continue;
            }
            
            Person *person = [mds personReader:blockSelf personWithUid:uid];
            if (!person)
                person = [[blockSelf dataSource] personReaderCreatePerson:blockSelf];
            person.uid = uid;
            person.first = first;
            person.last = last;
            person.middle = middle;
            
            [allUids addObject: uid];
        }
        
        NSSet *currentUids = [mds personReaderAllPersonsUids:blockSelf];
        
        for (NSString *uid in currentUids)
        {
            if (![allUids containsObject: uid])
            {
                Person *person = [mds personReader:blockSelf personWithUid:uid];
                if (person)
                    [mds personReader:blockSelf removeObject:person];
            }
        }
        
        [mds personReaderCommit:blockSelf];
        
    }];
    [self endSession];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc 
{
    [dataSource release];
    
    [super dealloc];
}
@end
