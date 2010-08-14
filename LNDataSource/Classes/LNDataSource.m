//
//  LNDataSource.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDataSource.h"
#import "Document.h"
#import "Resolution.h"
#import "Attachment.h"
#import "SynthesizeSingleton.h"
#import "ASINetworkQueue.h"
#import "LNHttpRequest.h"
#import "ASINetworkQueue.h"
#import "LotusViewParser.h"
#import "LotusDocumentParser.h"

static NSString *field_Uid         = @"UNID";
static NSString *field_Title       = @"title";
static NSString *field_Author      = @"author";
static NSString *field_Modified    = @"modified";
static NSString *field_Form        = @"form";
static NSString *field_Text        = @"text";

static NSString *form_Resolution   = @"Resolution";
static NSString *form_Signature    = @"Signature";
#warning debug data
    //static NSString *url_FetchView     = @"%@/%@/%@?ReadViewEntries&count=100";
static NSString *url_FetchView     = @"%@/%@/%@.xml?ReadViewEntries&count=100";
static NSString *url_FetchDocument = @"%@/%@/%@/%@?EditDocument";

@interface LNDataSource(Private)
- (void)fetchComplete:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)parseViewData:(NSString *) xmlFile;
- (void)fetchDocument:(Document *) document;
- (void)parseDocumentData:(Document *) document xmlFile:(NSString *) xmlFile;
- (void)saveDocument:(Document *) document;
- (void)loadSavedDocuments;
- (void)deleteDocument:(Document *) document;
- (NSString *) documentDirectory:(Document *) document;
@end

@implementation LNDataSource
SYNTHESIZE_SINGLETON_FOR_CLASS(LNDataSource);
@synthesize documentsListRefreshError, documents=_documents, viewReplicaId, databaseReplicaId, host;
-(id)init
{
    if ((self = [super init])) {
        _networkQueue = [[ASINetworkQueue alloc] init];
        [_networkQueue setRequestDidFinishSelector:@selector(fetchComplete:)];
        [_networkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
        [_networkQueue setDelegate:self];
        [_networkQueue go];
        
#warning test settings        
        self.host = @"http://vovasty/~vovasty";
        self.databaseReplicaId = @"C325777C0045161D";
        self.viewReplicaId = @"89FB7FB8A9330311C325777C004EEFC8";
        
        
        NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _databaseDirectory = [[[arrayPaths objectAtIndex:0]  stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.databaseReplicaId];
        [_databaseDirectory retain];

        [[NSFileManager defaultManager] createDirectoryAtPath:_databaseDirectory withIntermediateDirectories:TRUE 
                                                   attributes:nil error:nil]; 

        _viewDirectory = [_databaseDirectory stringByAppendingPathComponent:self.viewReplicaId];
        [_viewDirectory retain];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:_viewDirectory withIntermediateDirectories:TRUE 
                                                   attributes:nil error:nil]; 

        self.documents = [NSMutableDictionary dictionary];
        
        [self loadSavedDocuments];
        
    }
    return self;
}

-(void)dealloc
{
    [_networkQueue reset];
	[_networkQueue release];
    [_databaseDirectory release];
    [_viewDirectory release];
	self.documents = nil;
    
    [super dealloc];
}

-(void) refreshDocuments
{
    LNHttpRequest *request;
    NSString *url = [NSString stringWithFormat:url_FetchView, self.host, self.databaseReplicaId, self.viewReplicaId];
	request = [LNHttpRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDownloadDestinationPath:[_viewDirectory stringByAppendingPathComponent:@"index.xml"]];
    __block LNDataSource *blockSelf = self;
    request.requestHandler = ^(ASIHTTPRequest *request) {
        if ([request error] == nil  && [request responseStatusCode] == 200)
            [blockSelf parseViewData:[request downloadDestinationPath]];
        else
        {
            blockSelf->documentsListRefreshError = [[request error] localizedDescription];
            NSLog(@"error fetching url %@\n%@", [request originalURL], blockSelf->documentsListRefreshError);
        }
    };
	[_networkQueue addOperation:request];
}

@end

@implementation LNDataSource(Private)
#pragma mark -
#pragma mark ASINetworkQueue delegate
- (void)fetchComplete:(ASIHTTPRequest *)request
{
    void (^handler)(ASIHTTPRequest *request) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler(request);
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
    void (^handler)(ASIHTTPRequest *request) = ((LNHttpRequest *)request).requestHandler;
    if (handler)
        handler(request);
}

- (void)parseViewData:(NSString *) xmlFile
{
    LotusViewParser *parser = [LotusViewParser parseView:xmlFile];
    NSUInteger size = [parser.documentEntries count];
    NSMutableDictionary *newDocuments = [[NSMutableDictionary alloc] initWithCapacity:size];
    NSMutableDictionary *updatedDocuments = [[NSMutableDictionary alloc] initWithCapacity:size];
    NSMutableSet *allUids = [[NSMutableSet alloc] initWithCapacity:size];
    NSMutableArray *uidsToRemove = [[NSMutableArray alloc] initWithCapacity:size];
    for (NSDictionary *entry in parser.documentEntries) 
    {
        NSString *uid = [entry objectForKey:field_Uid];
        Document *document = [self.documents objectForKey:uid];
        [allUids addObject:uid];
            //new document
        if (document == nil)
        {
            NSString *form = [entry objectForKey:field_Form];
            if ([form isEqualToString:form_Resolution])
                document = [[Resolution alloc] init];
            else if ([form isEqualToString:form_Signature])
                document = [[Document alloc] init];
            else
            {
                NSLog(@"wrong form, document skipped: %@ %@", uid, form);
                continue;
            }
            document.title = [entry objectForKey:field_Title];
            document.uid = uid;
            document.author = [entry objectForKey:field_Author];
            document.dateModified = [entry objectForKey:field_Modified];
            [newDocuments setObject:document forKey:uid];
            [document release];
        }
        else
        {
            NSDate *newDate = [entry objectForKey:field_Modified];
                //document updated
            if ([document.dateModified compare: newDate] == NSOrderedAscending)
            {
                document.title = [entry objectForKey:field_Title];
                document.author = [entry objectForKey:field_Author];
                document.dateModified = newDate;
                [updatedDocuments setObject:document forKey:document.uid];
            }
        }
    }
    
        //remove obsoleted documents
    for (NSString *uid in [self.documents allKeys])
    {
        if (![allUids containsObject:uid])
            [uidsToRemove addObject:uid];
    }
        //remove documents
    if ([uidsToRemove count])
    {
        NSArray *removedDocuments = [self.documents objectsForKeys:uidsToRemove notFoundMarker:@""];
        [self.documents removeObjectsForKeys:uidsToRemove];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsRemoved" object:removedDocuments];
        for(Document *document in removedDocuments)
            [self deleteDocument:document];
        
    }
        //add new dowuments
    if ([newDocuments count])
    {
        [self.documents addEntriesFromDictionary:newDocuments];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsAdded" object:[newDocuments allValues]];
    }

        //update documents
    if ([updatedDocuments count])
    {
        [self.documents addEntriesFromDictionary:updatedDocuments];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsUpdated" object:[updatedDocuments allValues]];
    }
        //fetch new documents
    for (Document *document in [newDocuments allValues])
        [self fetchDocument: document];

        //refetch updated documents
    for (Document *document in [updatedDocuments allValues])
        [self fetchDocument: document];

    [uidsToRemove release];
    [allUids release];
    [newDocuments release];
    [updatedDocuments release];
}

- (void)fetchDocument:(Document *) document
{
    LNHttpRequest *request;
    NSString *url = [NSString stringWithFormat:url_FetchDocument, self.host, self.databaseReplicaId, self.viewReplicaId, document.uid];
	request = [LNHttpRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDownloadDestinationPath:[[self documentDirectory:document] stringByAppendingPathComponent:@"index.html"]];
    request.requestHandler = ^(ASIHTTPRequest *request) {
        if ([request error] == nil  && [request responseStatusCode] == 200)
            [self parseDocumentData:document xmlFile:[request downloadDestinationPath]];
        else
        {
            document.hasError = YES;
            NSLog(@"error fetching url: %@\nerror: %@\nresponseCode:%d", [request originalURL], [[request error] localizedDescription], [request responseStatusCode]);
        }
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DocumentsUpdated" object:[NSArray arrayWithObject:document]];
    };
	[_networkQueue addOperation:request];
}
- (NSString *) documentDirectory:(Document *) document
{
    NSString *directory = [_viewDirectory stringByAppendingPathComponent:document.uid];
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:TRUE 
                                               attributes:nil error:nil];
    return directory;
}
- (void)saveDocument:(Document *) document
{
    NSString * path = [self documentDirectory:document];
    
    [NSKeyedArchiver archiveRootObject: document toFile: [path stringByAppendingPathComponent:@"index.object"]];
    NSLog(@"saved to: %@", [path stringByAppendingPathComponent:@"index.object"]);
    
}
- (void)parseDocumentData:(Document *) document xmlFile:(NSString *) xmlFile;
{
    LotusDocumentParser *parser = [LotusDocumentParser parseDocument:xmlFile];
    NSDictionary *parsedDocument = parser.documentEntry;
    if ([document isKindOfClass:[Resolution class]]) 
    {
       ((Resolution *)document).text = [parsedDocument objectForKey:field_Text];
    }
    document.author = [parsedDocument objectForKey:field_Author];
    
    document.hasError = NO;
    document.loaded = YES;
    [self saveDocument:document];
}
- (void)loadSavedDocuments
{
    
    NSFileManager *df = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [df enumeratorAtPath:_viewDirectory];
    
    NSString *file;
    while (file = [dirEnum nextObject]) {
        NSString *documentObjectPath = [_viewDirectory stringByAppendingPathComponent: [file stringByAppendingPathComponent:@"index.object"] ];
        if ([df fileExistsAtPath:documentObjectPath isDirectory:NULL]) 
        {
            Document *document = [NSKeyedUnarchiver unarchiveObjectWithFile:documentObjectPath];
            [self.documents setObject:document forKey:document.uid];
        }
    }
}
- (void)deleteDocument:(Document *) document
{
    NSFileManager *df = [NSFileManager defaultManager];
    NSString *documentPath = [self documentDirectory:document];
    [df removeItemAtPath:documentPath error:NULL];
}
@end
