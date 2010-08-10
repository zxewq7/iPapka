//
//  Document.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Document : NSObject {
    NSString *uid;
    NSString *title;
    NSString *remoteUrl;
    UIImage  *icon;
}

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *remoteUrl;
@property (nonatomic, retain) UIImage  *icon;
@end
