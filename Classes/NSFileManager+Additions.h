//
//  NSFileManager+Additions.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 21.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager(NSFileManagerAdditions) 
+(NSString *) tempFileName:(NSString *) prefix;
@end
