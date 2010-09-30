//
//  PerformersViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewWithButtons, DocumentResolution, PersonPickerViewController;

@interface PerformersViewController : UIViewController
{
    NSMutableArray *performers;
    ViewWithButtons *performersView;
    DocumentResolution *document;
    NSArray *sortByLastDescriptors;  
    UIPopoverController *popoverController;
    PersonPickerViewController *personPickerViewController;
}

@property (nonatomic, retain) DocumentResolution *document;
@end
