//
//  Comment.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Comment : NSObject {
    NSString     *author;
    NSDate       *date;
    NSString     *text;
}

@property (nonatomic, retain) NSString     *author;
@property (nonatomic, retain) NSDate       *date;
@property (nonatomic, retain) NSString     *text;
@end
