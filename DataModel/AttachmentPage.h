//
//  AttachmentPage.h
//  DataModel
//
//  Created by Vladimir Solomenchuk on 29.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AttachmentPage : NSObject<NSCoding> 
{
    NSString *name;
    NSArray  *curves;
    BOOL     hasError;
    BOOL     isLoaded;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray  *curves;
@property (nonatomic, assign) BOOL    hasError;
@property (nonatomic, assign) BOOL    isLoaded;
@end
