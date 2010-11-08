//
//  NSDate+Additions.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 25.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//  http://www.bdunagan.com/2008/09/13/cocoa-tutorial-yesterday-today-and-tomorrow-with-nsdate/
//

#import <Foundation/Foundation.h>


@interface NSDateFormatter (DateForNow)

-(NSString *) stringForDateFromNow:(NSDate *)date;
@end
