//
//  Document.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Document : NSObject<NSCoding> {
    NSString     *title;
    NSString     *author;
    NSDate       *date;
    NSArray      *comments;
    NSArray      *attachments;

    NSString     *remoteUrl;
    NSString     *uid;
    NSDate       *dateModified;
    BOOL         loaded;
    BOOL         hasError;
}

@property (nonatomic, retain) NSString     *title;
@property (nonatomic, readonly) UIImage      *icon;
@property (nonatomic, retain) NSString     *author;
@property (nonatomic, retain) NSDate       *date;
@property (nonatomic, retain) NSArray      *comments;
@property (nonatomic, retain) NSArray      *attachments;

@property (nonatomic, retain) NSString     *remoteUrl;
@property (nonatomic, retain) NSString     *uid;
@property (nonatomic, retain) NSDate       *dateModified;
@property (nonatomic)         BOOL         loaded;
@property (nonatomic)         BOOL         hasError;
@end
