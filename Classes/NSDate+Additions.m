//
//  NSDate+Additions.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 25.11.10.
//  Copyright 2010 Intertrust Company. All rights reserved.
//

#import "NSDate+Additions.h"


@implementation NSDate(NSDate_Additions)
-(NSDate*) stripTime
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *comps;
    
    comps = [calendar components:unitFlags fromDate:self];
    return [calendar dateFromComponents:comps];
}
@end
