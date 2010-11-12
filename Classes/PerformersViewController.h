//
//  PerformersViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewWithButtons, DocumentResolutionAbstract;

@interface PerformersViewController : UIViewController
{
    NSMutableArray *performers;
    ViewWithButtons *performersView;
    DocumentResolutionAbstract *document;
    UIPopoverController *personPopoverController;
    UIButton *buttonAdd;
}

@property (nonatomic, retain) DocumentResolutionAbstract *document;
@end
