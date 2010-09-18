//
//  ResolutionViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 13.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged, DatePickerController;
@interface ResolutionViewController : UIViewController <UITextViewDelegate>
{
    UISegmentedControl *resolutionSwitcher;
    UIImageView        *logo;
    UIButton           *deadlineButton;
    UITextView         *resolutionText;
    UILabel            *authorLabel;
    UILabel            *dateLabel;
    DocumentManaged    *document;
    NSDateFormatter    *dateFormatter;
    DatePickerController *datePickerController;
    UIPopoverController *popoverController;
}

@property (nonatomic, retain) DocumentManaged    *document;
@end
