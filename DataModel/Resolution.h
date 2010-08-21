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
    NSString            *text;
    NSMutableDictionary *performers;
    BOOL                managed;
    Resolution          *parentResolution;
}
@property (nonatomic, retain) NSString            *text;
@property (nonatomic, retain) NSMutableDictionary *performers;
@property (nonatomic)         BOOL                managed;
@property (nonatomic, retain) Resolution          *parentResolution;
@end
