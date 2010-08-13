//
//  LotusViewParser.h
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 12.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>


@interface LotusViewParser : NSObject {
        // Reference to the libxml parser context
    xmlParserCtxtPtr    context;
    NSAutoreleasePool   *parsePool;
    NSDateFormatter     *parseFormatterDst;
    NSDateFormatter     *parseFormatterSimple;
    NSMutableData       *characterBuffer;
    NSMutableDictionary *currentDocumentEntry;
    BOOL                storingCharacters;
    BOOL                parsingADocumentEntry;
    NSMutableArray      *documentEntries;
    NSUInteger          countOfParsedItems;
    NSString            *currentFieldName;
    BOOL                dateDst;
}

-(id) initWithFileName:(NSString *) fileName;
+(id) parseView:(NSString *) fileName;
    // The autorelease pool property is assign because autorelease pools cannot be retained.
@property (nonatomic, assign) NSAutoreleasePool   *parsePool;
@property (nonatomic, retain) NSDateFormatter     *parseFormatterDst;
@property (nonatomic, retain) NSDateFormatter     *parseFormatterSimple;
@property (nonatomic, retain) NSMutableData       *characterBuffer;
@property (nonatomic, retain) NSMutableDictionary *currentDocumentEntry;
@property (nonatomic, retain) NSMutableArray      *documentEntries;
@property (nonatomic, retain) NSString            *currentFieldName;
@property BOOL storingCharacters;
@property BOOL parsingADocumentEntry;
@property BOOL dateDst;

- (void)finishedDocumentEntry;
@end
