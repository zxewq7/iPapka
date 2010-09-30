//
//  PerformersViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewWithButtons, Resolution, PersonPickerViewController;

@interface PerformersViewController : UIViewController
{
    NSMutableArray *performers;
    ViewWithButtons *performersView;
    Resolution *document;
    NSArray *sortByLastDescriptors;  
    UIPopoverController *popoverController;
    PersonPickerViewController *personPickerViewController;
}

@property (nonatomic, retain) Resolution *document;
@end
