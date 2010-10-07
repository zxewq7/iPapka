//
//  IntRow.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 07.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListElement;
@interface IntRow : NSObject 
{
    ListElement *top;
    ListElement *last;
    NSUInteger maxSize;
    NSUInteger size;
}

- (void) add: (NSUInteger) value;
@property (readonly) NSUInteger median;
@property NSUInteger maxSize;
@end
