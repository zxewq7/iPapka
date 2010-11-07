//
//  ResolutionViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 13.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentResolution, DatePickerController, PerformersViewController, SSTextView, AudioCommentController, ResolutionContentView;
@interface ResolutionViewController : UIViewController <UITextViewDelegate, UIPopoverControllerDelegate>
{
    UISegmentedControl *resolutionSwitcher;
    UIButton           *deadlineButton;
    UILabel            *deadlineLabel;
    SSTextView         *resolutionText;
    UILabel            *authorLabel;
    UILabel            *dateLabel;
    DocumentResolution   *document;
    NSDateFormatter    *dateFormatter;
    DatePickerController *datePickerController;
    UIPopoverController *popoverController;
    PerformersViewController *performersViewController;
    UISwitch            *managedButton;
    AudioCommentController *audioCommentController;
    ResolutionContentView *contentView;
    CGSize              minSize;
}

@property (nonatomic, retain) DocumentResolution    *document;
@end
