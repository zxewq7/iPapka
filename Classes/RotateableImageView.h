//
//  RotateableImageView.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 16.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RotateableImageView : UIImageView 
{
    UIImage *portraitImage;
    UIImage *landscapeImage;
    BOOL prevOrientationPortrait;
}

@property (nonatomic, retain) UIImage *portraitImage;
@property (nonatomic, retain) UIImage *landscapeImage;
@end
