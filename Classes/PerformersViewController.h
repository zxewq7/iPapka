//
//  PerformersViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewWithButtons, ResolutionManaged, PersonPickerViewController;

@interface PerformersViewController : UIViewController
{
    NSMutableArray *performers;
    ViewWithButtons *performersView;
    ResolutionManaged *document;
    NSArray *sortByLastDescriptors;  
    UIPopoverController *popoverController;
    PersonPickerViewController *personPickerViewController;
}

@property (nonatomic, retain) ResolutionManaged *document;
@end
