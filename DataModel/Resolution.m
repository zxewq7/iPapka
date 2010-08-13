//
//  Resolution.m
//  DataModel
//
//  Created by Vladimir Solomenchuk on 13.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Resolution.h"


@implementation Resolution
@synthesize text, performers, managed;

- (void) dealloc
{
    self.text = nil;
    self.performers = nil;
    [super dealloc];
}

@dynamic icon;
- (UIImage *) icon
{
    return [UIImage imageNamed: hasError?@"ResolutionError.png":loaded?@"Resolution.png":@"ResolutionNotLoaded.png"];
}

@end
