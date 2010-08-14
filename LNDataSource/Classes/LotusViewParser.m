//
//  LotusViewParser.m
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 12.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LotusViewParser.h"
#import <libxml/tree.h>
#include <sys/stat.h>
#include <fcntl.h>

#define BUF_SIZE 8192

static NSString *UNID_ATTRIBUTE = @"UNID"; 

    // Function prototypes for SAX callbacks. This sample implements a minimal subset of SAX callbacks.
    // Depending on your application's needs, you might want to implement more callbacks.
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

    // Forward reference. The structure is defined in full at the end of the file.
static xmlSAXHandler simpleSAXHandlerStruct;

@implementation LotusViewParser
@synthesize parsePool, dateDst, parseFormatterSimple, parseFormatterDst, characterBuffer, currentDocumentEntry, storingCharacters, parsingADocumentEntry, documentEntries, currentFieldName;

-(id) initWithFileName:(NSString *) fileName
{
    if ((self = [super init])) 
    {
        self.documentEntries = [NSMutableArray arrayWithCapacity:10];
        self.parsePool = [[NSAutoreleasePool alloc] init];
        self.parseFormatterDst = [[[NSDateFormatter alloc] init] autorelease];
            //20100811T183249,89+04
        [self.parseFormatterDst setDateFormat:@"yyyyMMdd'T'HHmmss,S"];
        self.parseFormatterSimple = [[[NSDateFormatter alloc] init] autorelease];
            //20100811
        [self.parseFormatterSimple setDateFormat:@"yyyyMMdd"];
        countOfParsedItems = 0;
            // the date formatter must be set to US locale in order to parse the dates
        self.characterBuffer = [NSMutableData data];
            // This creates a context for "push" parsing in which chunks of data that are not "well balanced" can be passed
            // to the context for streaming parsing. The handler structure defined above will be used for all the parsing. 
            // The second argument, self, will be passed as user data to each of the SAX handlers. The last three arguments
            // are left blank to avoid creating a tree in memory.
        context = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
        
        
        
        
        if( fileName == nil ) { /* set *error */ return nil; }
        const char *filename = [fileName fileSystemRepresentation];
        
        if( filename == NULL ) { /* set error */ return nil; }
        
            // open the file and get a file descriptor for it
        int fd = open(filename, O_RDONLY);
        if( fd == -1 )
        {
            NSLog(@"%@", [NSError errorWithDomain: NSPOSIXErrorDomain code: errno userInfo: nil]);
            return nil;
        }
        
        const char bytes[BUF_SIZE];
        
        {
            for (NSUInteger length = read(fd, &bytes, BUF_SIZE);length>0;length = read(fd, &bytes, BUF_SIZE))
            {
                xmlParseChunk(context, (const char *)bytes, length, 0);
            }
        }
        
        close(fd);
        
        
        
            // Release resources used only in this thread.
        xmlFreeParserCtxt(context);
        self.characterBuffer = nil;
        self.parseFormatterDst = nil;
        self.parseFormatterSimple = nil;
        self.currentDocumentEntry = nil;
        self.currentFieldName = nil;
        [parsePool release];
        self.parsePool = nil;        
    }
    return self;
}
+(id) parseView:(NSString *) fileName
{
    return [[[LotusViewParser alloc] initWithFileName:fileName] autorelease];
}




#pragma mark Parsing support methods

static const NSUInteger kAutoreleasePoolPurgeFrequency = 20;

- (void)finishedDocumentEntry {
    [self.documentEntries addObject:self.currentDocumentEntry];
        // performSelectorOnMainThread: will retain the object until the selector has been performed
        // setting the local reference to nil ensures that the local reference will be released
    self.currentDocumentEntry = nil;
    countOfParsedItems++;
        // Periodically purge the autorelease pool. The frequency of this action may need to be tuned according to the 
        // size of the objects being parsed. The goal is to keep the autorelease pool from growing too large, but 
        // taking this action too frequently would be wasteful and reduce performance.
    if (countOfParsedItems == kAutoreleasePoolPurgeFrequency) {
        [parsePool release];
        self.parsePool = [[NSAutoreleasePool alloc] init];
        countOfParsedItems = 0;
    }
}

/*
 Character data is appended to a buffer until the current element ends.
 */
- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length {
    [characterBuffer appendBytes:charactersFound length:length];
}

- (NSString *)currentString {
        // Create a string with the character data using UTF-8 encoding. UTF-8 is the default XML data encoding.
    NSString *currentString = [[[NSString alloc] initWithData:characterBuffer encoding:NSUTF8StringEncoding] autorelease];
    [characterBuffer setLength:0];
    return currentString;
}

- (NSString *)findAttribute:(int) nb_attributes attributes:(const xmlChar **)attributes name:(const char *)name length:(NSUInteger) length;
{
    unsigned int index = 0;
    for ( int indexAttribute = 0; 
         indexAttribute < nb_attributes; 
         ++indexAttribute, index += 5 )
    {
        const xmlChar *localname = attributes[index];
        if (strncmp((const char *)localname, name, length))
            continue;
//        const xmlChar *prefix = attributes[index+1];
//        const xmlChar *nsURI = attributes[index+2];
        const xmlChar *valueBegin = attributes[index+3];
        const xmlChar *valueEnd = attributes[index+4];
        NSData *dataResult = [NSData dataWithBytes:(const char *)valueBegin length:(const char *)valueEnd-(const char *)valueBegin];
        NSString *stringValue = [[NSString alloc] initWithData:dataResult encoding: NSUTF8StringEncoding];
        return [stringValue autorelease];
    }
    return @"oops";
}
@end

#pragma mark SAX Parsing Callbacks

    // The following constants are the XML element names and their string lengths for parsing comparison.
    // The lengths include the null terminator, to ensure exact matches.
static const char *kName_Item = "viewentry";
static const NSUInteger kLength_Item = 10;
static const char *kName_EntryData = "entrydata";
static const NSUInteger kLength_EntryData = 10;
static const char *kName_Datetime = "datetime";
static const NSUInteger kLength_Datetime = 9;
static const char *kName_Text = "text";
static const NSUInteger kLength_Text = 5;
static const char *kName_Unid = "unid";
static const NSUInteger kLength_Unid = 4;
static const char *kName_Name = "name";
static const NSUInteger kLength_Name = 5;
static const char *kName_Dst = "dst";
static const NSUInteger kLength_Dst = 4;


/*
 This callback is invoked when the parser finds the beginning of a node in the XML. For this application,
 out parsing needs are relatively modest - we need only match the node name. An "item" node is a record of
 data about a song. In that case we create a new Song object. The other nodes of interest are several of the
 child nodes of the Song currently being parsed. For those nodes we want to accumulate the character data
 in a buffer. Some of the child nodes use a namespace prefix. 
 */
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, 
                            int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes) {
    LotusViewParser *parser = (LotusViewParser *)ctx;
        // The second parameter to strncmp is the name of the element, which we known from the XML schema of the feed.
        // The third parameter to strncmp is the number of characters in the element name, plus 1 for the null terminator.
    if (prefix == NULL && !strncmp((const char *)localname, kName_Item, kLength_Item)) {
        NSMutableDictionary *newDocumentEntry = [[NSMutableDictionary alloc] init];
        NSString *unid = [parser findAttribute:nb_attributes attributes:attributes name:kName_Unid length:kLength_Unid];
        [newDocumentEntry setObject:unid forKey:UNID_ATTRIBUTE];
        parser.currentDocumentEntry = newDocumentEntry;
        [newDocumentEntry release];
        parser.parsingADocumentEntry = YES;
    } else if (parser.parsingADocumentEntry && ( (prefix == NULL && (!strncmp((const char *)localname, kName_EntryData, kLength_EntryData))) )) {
        NSString *fieldName = [parser findAttribute:nb_attributes attributes:attributes name:kName_Name length:kLength_Name];
        parser.currentFieldName = fieldName;
    } else if (parser.parsingADocumentEntry && ( (prefix == NULL && (!strncmp((const char *)localname, kName_Datetime, kLength_Datetime))) )) {
        parser.dateDst =  [parser findAttribute:nb_attributes attributes:attributes name:kName_Dst length:kLength_Dst] != nil;
        parser.storingCharacters = YES;
    } else if (parser.parsingADocumentEntry && ( (prefix == NULL && !strncmp((const char *)localname, kName_Text, kLength_Text)) )) {
        parser.storingCharacters = YES;
    }
}

/*
 This callback is invoked when the parse reaches the end of a node. At that point we finish processing that node,
 if it is of interest to us. For "item" nodes, that means we have completed parsing a Song object. We pass the song
 to a method in the superclass which will eventually deliver it to the delegate. For the other nodes we
 care about, this means we have all the character data. The next step is to create an NSString using the buffer
 contents and store that with the current Song object.
 */
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) {    
    LotusViewParser *parser = (LotusViewParser *)ctx;
    if (parser.parsingADocumentEntry == NO) return;
    if (prefix == NULL) {
        if (!strncmp((const char *)localname, kName_Item, kLength_Item)) {
            [parser finishedDocumentEntry];
            parser.parsingADocumentEntry = NO;
        } else if (!strncmp((const char *)localname, kName_Text, kLength_Text)) {
            [parser.currentDocumentEntry setObject:[parser currentString] forKey:parser.currentFieldName];
        } else if (!strncmp((const char *)localname, kName_Datetime, kLength_Datetime)) {
            NSString *dateString = [parser currentString];
            NSDate *date;
#warning truncated time zone
            if (parser.dateDst)
            {
                dateString = [dateString substringToIndex:[dateString length]-3];
                date = [parser.parseFormatterDst dateFromString:dateString];
            }
            else
                date = [parser.parseFormatterSimple dateFromString:dateString];
            if (date)
                [parser.currentDocumentEntry setObject:date forKey:parser.currentFieldName];
            else 
                NSLog(@"Unparseable date: %@", [parser currentString]);

        }
    }
    parser.storingCharacters = NO;
}

/*
 This callback is invoked when the parser encounters character data inside a node. The parser class determines how to use the character data.
 */
static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
    LotusViewParser *parser = (LotusViewParser *)ctx;
        // A state variable, "storingCharacters", is set when nodes of interest begin and end. 
        // This determines whether character data is handled or ignored. 
    if (parser.storingCharacters == NO) return;
    [parser appendCharacters:(const char *)ch length:len];
}

/*
 A production application should include robust error handling as part of its parsing implementation.
 The specifics of how errors are handled depends on the application.
 */
static void errorEncounteredSAX(void *ctx, const char *msg, ...) {
        // Handle errors as appropriate for your application.
    NSCAssert(NO, @"Unhandled error encountered during SAX parse.");
}

    // The handler struct has positions for a large number of callback functions. If NULL is supplied at a given position,
    // that callback functionality won't be used. Refer to libxml documentation at http://www.xmlsoft.org for more information
    // about the SAX callbacks.
static xmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    startElementSAX,            /* startElementNs */
    endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};