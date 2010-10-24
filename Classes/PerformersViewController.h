//
//  PerformersViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewWithButtons, DocumentResolutionAbstract, PersonPickerViewController;

@interface PerformersViewController : UIViewController
{
    NSMutableArray *performers;
    ViewWithButtons *performersView;
    DocumentResolutionAbstract *document;
    UIPopoverController *popoverController;
    PersonPickerViewController *personPickerViewController;
    UIButton *buttonAdd;
}

@property (nonatomic, retain) DocumentResolutionAbstract *document;
@end
