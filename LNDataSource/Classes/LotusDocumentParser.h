//
//  LotusViewParser.h
//  LNDataSource
//
//  Created by Vladimir Solomenchuk on 12.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>


@interface LotusDocumentParser : NSObject {
        // Reference to the libxml parser context
    xmlParserCtxtPtr    context;
    NSAutoreleasePool   *parsePool;
    NSDateFormatter     *parseFormatter;
    NSMutableData       *characterBuffer;
    BOOL                storingCharacters;
    BOOL                parsingADocumentEntry;
    NSUInteger          countOfParsedItems;
    NSString            *currentFieldName;
    NSString            *currentFieldType;
    NSMutableDictionary *currentDocumentEntry;
    NSMutableArray      *documentStack;
    NSMutableDictionary *documentEntry;
    NSMutableArray      *currentList;
    NSMutableArray      *listStack;
}

-(id) initWithFileName:(NSString *) fileName;
+(id) parseDocument:(NSString *) fileName;
    // The autorelease pool property is assign because autorelease pools cannot be retained.
@property (nonatomic, assign) NSAutoreleasePool   *parsePool;
@property (nonatomic, retain) NSDateFormatter     *parseFormatter;
@property (nonatomic, retain) NSMutableData       *characterBuffer;
@property (nonatomic, retain) NSMutableDictionary *currentDocumentEntry;
@property (nonatomic, retain) NSString            *currentFieldName;
@property (nonatomic, retain) NSString            *currentFieldType;
@property BOOL storingCharacters;
@property BOOL parsingADocumentEntry;
@property (nonatomic, retain) NSMutableArray      *documentStack;
@property (nonatomic, retain) NSMutableDictionary *documentEntry;
@property (nonatomic, retain) NSMutableArray      *currentList;
@property (nonatomic, retain) NSMutableArray      *listStack;

- (void)finishedDocumentEntry;
@end
