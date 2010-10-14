//
//  LNPersonReader.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 13.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNPersonReader.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "PasswordManager.h"
#import "SBJsonParser.h"
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
    self.allRequestsSent = NO;
    
    LNHttpRequest *request = [LNHttpRequest requestWithURL:[NSURL URLWithString: url]];
    request.delegate = self;
    
    id<LNPersonReaderDataSource> mds = [self dataSource];

    __block LNPersonReader *blockSelf = self;

    [self sendRequestWithUrl:url andHandler:^(BOOL err, NSString *response){
        if (err)
            return;

        SBJsonParser *json = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSString *jsonString = response;
        NSArray *parsedResponse = [json objectWithString:jsonString error:&error];
        [json release];
        if (parsedResponse == nil)
        {
            NSLog(@"error parsing response, error:%@ response: %@", error, jsonString);
            return;
        }
        
        NSMutableSet *allUids = [NSMutableSet setWithCapacity:[parsedResponse count]];
        
        for (NSDictionary *personDict in parsedResponse)
        {
            NSString *uid = [personDict objectForKey:kFieldUid];
            NSString *first = [personDict objectForKey:kFieldFirst];
            NSString *last = [personDict objectForKey:kFieldLast];
            NSString *middle = [personDict objectForKey:kFieldMiddle];
            
            if (!(uid && first && last))
            {
                blockSelf.hasError = YES;
                NSLog(@"not enough person attributes, skipped %@", personDict);
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
    self.allRequestsSent = YES;
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc 
{
    [dataSource release];
    
    [super dealloc];
}
@end
