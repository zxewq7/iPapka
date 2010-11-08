//
//  RootContentView.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 21.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RotateableImageView.h"

@interface RootContentView : RotateableImageView  

@property (nonatomic, retain) UIView *documentInfo;
@property (nonatomic, retain) UIView *attachments;
@property (nonatomic, retain) UIView *resolution;
@property (nonatomic, retain) UIView *signatureComment;
@end
