//
//  PerformersViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewWithButtons;

@interface PerformersViewController : UIViewController
{
    NSMutableArray *performers;
    ViewWithButtons *performersView;
    UIPopoverController *personPopoverController;
    UIButton *buttonAdd;
    id<NSObject>target;
    SEL action;
    BOOL isEditable;
}
-(void) setPerformers:(NSMutableArray *)performers isEditable:(BOOL)isEditable;
@property (nonatomic, retain) id<NSObject>target;
@property (nonatomic) SEL action;
@end
