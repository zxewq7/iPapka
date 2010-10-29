//
//  ResolutionViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 13.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentResolution, DatePickerController, PerformersViewController, TextViewWithPlaceholder, AudioCommentController;
@interface ResolutionViewController : UIViewController <UITextViewDelegate, UIPopoverControllerDelegate>
{
    UISegmentedControl *resolutionSwitcher;
    UIButton           *deadlineButton;
    UILabel            *deadlineLabel;
    TextViewWithPlaceholder         *resolutionText;
    UILabel            *authorLabel;
    UILabel            *dateLabel;
    DocumentResolution   *document;
    NSDateFormatter    *dateFormatter;
    DatePickerController *datePickerController;
    UIPopoverController *popoverController;
    PerformersViewController *performersViewController;
    UISwitch            *managedButton;
    AudioCommentController *audioCommentController;
}

@property (nonatomic, retain) DocumentResolution    *document;
@end
