//
//  NSString+Additions.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 02.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+Additions.h"


@implementation NSString(NSStringAdditions)
+ (NSString *) intervalString: (NSTimeInterval) interval
{
    NSUInteger hours = floor(interval/3600);
    NSUInteger minutes = floor(round(interval - hours * 3600)/60);
    NSUInteger seconds = round(interval - hours * 3600 - minutes * 60);
    
    NSMutableString * result = [[NSMutableString new] autorelease];
    
    if(hours)
        [result appendFormat: @"%d:", hours];
    
    [result appendFormat: @"%02d:", minutes];
    
    [result appendFormat: @"%02d", seconds];
    
    return result;
}
@end
