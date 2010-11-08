//
//  NSDate+Additions.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 25.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDateFormatter+Additions.h"


@implementation NSDateFormatter (DateForNow)
-(NSString *) stringForDateFromNow:(NSDate *)date
{
	// Initialize the calendar and flags.
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
	NSCalendar *calendar = [NSCalendar currentCalendar];
    
	// Create reference date for supplied date.
	NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	NSDate *suppliedDate = [calendar dateFromComponents:comps];
    
	// Iterate through the eight days (tomorrow, today, and the last six).
	int i;
	for (i = -1; i < 7; i++)
	{
		// Initialize reference date.
		comps = [calendar components:unitFlags fromDate:[NSDate date]];
		[comps setHour:0];
		[comps setMinute:0];
		[comps setSecond:0];
		[comps setDay:[comps day] - i];
		NSDate *referenceDate = [calendar dateFromComponents:comps];
		// Get week day (starts at 1).
		int weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
        
		if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1)
		{
			// Tomorrow
			return NSLocalizedString(@"Tomorrow", "Tomorrow");
		}
		else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0)
		{
			// Today
            return NSLocalizedString(@"Today", "Today");
		}
		else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1)
		{
			// Yesterday
			return NSLocalizedString(@"Yesterday", "Yesterday");
		}
		else if ([suppliedDate compare:referenceDate] == NSOrderedSame)
		{
			// Day of the week
			NSString *day = [[self weekdaySymbols] objectAtIndex:weekday];
			return day;
		}
	}
    
	// It's not in those eight days.
	NSString *defaultDate = [self stringFromDate:date];
	return defaultDate;
}
@end
