//
//  IntRow.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 07.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListElement;
@interface IntRow : NSObject 
{
    NSMutableArray *queue;
    NSUInteger maxSize;
}

- (void) add: (NSInteger) value;
@property (readonly) NSInteger median;
@property NSUInteger maxSize;
@end
