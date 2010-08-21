//
//  Document.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

@interface Document : NSObject<NSCoding> {
    NSString     *title;
    NSString     *author;
    NSDate       *date;
    NSArray      *attachments;
    NSNumber     *isRead;

    NSString     *uid;
    NSDate       *dateModified;
    BOOL         isLoaded;
    BOOL         hasError;
}

@property (nonatomic, retain) NSString     *title;
@property (nonatomic, retain) NSString     *author;
@property (nonatomic, retain) NSDate       *date;
@property (nonatomic, retain) NSArray      *attachments;
@property (nonatomic, retain) NSNumber     *isRead;

@property (nonatomic, retain) NSString     *uid;
@property (nonatomic, retain) NSDate       *dateModified;
@property (nonatomic)         BOOL         isLoaded;
@property (nonatomic)         BOOL         hasError;
@end
