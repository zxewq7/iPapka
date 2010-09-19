//
//  RootBackgroundView.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 19.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotateableImageView.h"

@interface RootBackgroundView : RotateableImageView 

@property (nonatomic, retain) UIView *paper;
@property (nonatomic, retain) UIView *paintingTools;
@property (nonatomic, retain) UIView *content;
@property (nonatomic, retain) UIView *infoButton;
@property (nonatomic, retain) UIView *resolutionButton;
@property (nonatomic, retain) UIView *backButton;

@end
