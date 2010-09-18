//
//  ColorPicker.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 18.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColorPicker : UITableViewController 
{
    UIColor *color;
    SEL selector;
    id target;
    
}

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) id target;

@end
