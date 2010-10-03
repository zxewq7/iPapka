//
//  NSString+Additions.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 02.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(NSStringAdditions)
+ (NSString *) timeString: (uint64_t) seconds showSeconds: (BOOL) showSeconds;
+ (NSString *) timeString: (uint64_t) seconds showSeconds: (BOOL) showSeconds maxFields: (NSUInteger) max;
@end
