//
//  Comment.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Comment : NSObject<NSCoding> {
    NSString     *author;
    NSDate       *date;
    NSString     *text;
}

@property (nonatomic, retain) NSString     *author;
@property (nonatomic, retain) NSDate       *date;
@property (nonatomic, retain) NSString     *text;
@end
