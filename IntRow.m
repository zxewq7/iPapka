//
//  IntRow.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 07.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "IntRow.h"

@implementation IntRow
@synthesize maxSize, median;
- (id)init
{
    if ((self = [super init])) 
    {
        queue = [[NSMutableArray alloc] init];
        maxSize = 0;
    }
    return self;
}

-(void) add: (NSInteger) value
{
    NSNumber *newElement = [[NSNumber alloc] initWithInteger:value];
    
    [queue insertObject:newElement atIndex:0];
    
    [newElement release];
    
    if (maxSize && maxSize < [queue count])
        [queue removeLastObject];
}

- (NSInteger) median
{
    NSInteger m = 0;
    for (NSNumber *x in queue)
        m += [x integerValue];
    
    return m / [queue count];
}

- (void)dealloc 
{
    [queue release];

    [super dealloc];
}
@end
