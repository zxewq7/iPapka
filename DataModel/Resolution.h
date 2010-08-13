//
//  Resolution.h
//  DataModel
//
//  Created by Vladimir Solomenchuk on 13.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Document.h"

@interface Resolution : Document<NSCoding> {
    NSString     *text;
    NSDictionary *performers;
    BOOL         managed;
}
@property (nonatomic, retain) NSString     *text;
@property (nonatomic, retain) NSDictionary *performers;
@property (nonatomic)         BOOL         managed;
@end
