//
//  IntRow.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 07.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "IntRow.h"

@interface ListElement : NSObject 
{
    NSUInteger value;
    ListElement *next;
    ListElement *prev;
}
@property (nonatomic) NSUInteger value;
@property (nonatomic, retain) ListElement *next;
@property (nonatomic, retain) ListElement *prev;
@end

@implementation ListElement
@synthesize value, next, prev;

- (void)dealloc 
{
    self.next = nil;
    self.prev = nil;
    [super dealloc];
}

@end

@implementation IntRow
@synthesize maxSize;
- (id)init
{
    if ((self = [super init])) 
    {
        top = nil;
        last = nil;
        maxSize = 0;
        size = 0;
    }
    return self;
}

-(void) add: (NSUInteger) value
{
    ListElement *newElement = [[ListElement alloc] init];
    newElement.value = value;
    
    if (!top)
    {
        top = newElement;
        last = newElement;
    }
    else
    {
        newElement.next = top;
        newElement.prev = nil;
        top.prev = newElement;
        
        top = newElement;
        
    }
    size ++;
    if (maxSize && maxSize < size)
    {
        ListElement *prev = last.prev;
        last.prev = nil;
        prev.next = nil;
        [last release];
        last = prev;
        size --;
    }
}

- (NSUInteger) median
{
    if (!size)
        return 0;
    
    NSUInteger median = 0;
    for (ListElement *x = top; x; x = x.next)
        median += x.value;
    
    return median / size;
}

- (void)dealloc 
{
    [top release];
    [super dealloc];
}
@end
