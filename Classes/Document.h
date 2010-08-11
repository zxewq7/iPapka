//
//  Document.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Document : NSObject {
    NSString     *title;
    UIImage      *icon;
    NSString     *author;
    NSDate       *date;
    NSString     *text;
    NSDictionary *performers;
    BOOL         underControl;

    NSString     *remoteUrl;
    NSString     *uid;
}

@property (nonatomic, retain) NSString     *title;
@property (nonatomic, retain) UIImage      *icon;
@property (nonatomic, retain) NSString     *author;
@property (nonatomic, retain) NSDate       *date;
@property (nonatomic, retain) NSString     *text;
@property (nonatomic, retain) NSDictionary *performers;
@property (nonatomic)         BOOL         underControl;

@property (nonatomic, retain) NSString     *remoteUrl;
@property (nonatomic, retain) NSString     *uid;
@end
