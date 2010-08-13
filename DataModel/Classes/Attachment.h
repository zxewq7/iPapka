//
//  Attachment.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Attachment : NSObject<NSCoding> {
    NSString     *title;
    UIImage      *_icon;
    NSString     *remoteUrl;
}

@property (nonatomic, retain)           NSString     *title;
@property (nonatomic, retain, readonly) UIImage      *icon;
@property (nonatomic, retain)           NSString     *remoteUrl;

@end
