//
//  Attachment.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Attachment : NSObject<NSCoding> {
    NSString     *title;
    NSDictionary *pages;
    NSString     *path;
    BOOL         isLoaded;
    BOOL         hasError;
}

@property (nonatomic, retain) NSString     *title;
@property (nonatomic, retain) NSDictionary *pages;
@property (nonatomic, retain) NSString     *path;

@property (nonatomic)         BOOL         isLoaded;
@property (nonatomic)         BOOL         hasError;
@end
