//
//  BubbleView.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//  http://steve.dynedge.co.uk/2010/03/09/rounded-corners-with-an-arrow-on-a-uiview-with-the-iphone-sdk-3-0/
//

#import <UIKit/UIKit.h>

typedef enum _AZZArrowPosition {
    // The four primary sides are compatible with the preferredEdge of NSDrawer.
    AZZPositionLeft          = 0,
    AZZPositionRight         = 1,
    AZZPositionTop           = 2,
    AZZPositionBottom        = 3
} AZZArrowPosition;

@interface AZZBubbleView : UIView 
{
    CGFloat pointY;
    CGFloat pointX;
    CGFloat pointWidth;
    CGFloat pointHeight;
    UIColor *rectColor;
    AZZArrowPosition arrowPosition;
}

@property (nonatomic, assign) CGFloat pointY; //to specify where on the left hand edge the point starts.
@property (nonatomic, assign) CGFloat pointX; //to specify where on the left hand edge the point starts.
@property (nonatomic, assign) CGFloat pointWidth;// to specify the width of the point.
@property (nonatomic, assign) CGFloat pointHeight;// for the height.
@property (nonatomic, assign) AZZArrowPosition arrowPosition;// for the height.

@property (nonatomic, retain) UIColor *rectColor;
@end
