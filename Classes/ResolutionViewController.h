//
//  ResolutionViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 13.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResolutionManaged, DatePickerController, PerformersViewController, AZZAudioRecorder, AZZAudioPlayer;
@interface ResolutionViewController : UIViewController <UITextViewDelegate, UIPopoverControllerDelegate>
{
    UISegmentedControl *resolutionSwitcher;
    UIImageView        *logo;
    UIButton           *deadlineButton;
    UITextView         *resolutionText;
    UILabel            *authorLabel;
    UILabel            *dateLabel;
    ResolutionManaged   *document;
    NSDateFormatter    *dateFormatter;
    DatePickerController *datePickerController;
    UIPopoverController *popoverController;
    PerformersViewController *performersViewController;
    AZZAudioRecorder    *recorder;
    AZZAudioPlayer      *player;
    UIButton            *playButton;
    UIButton            *recordButton;
    UISwitch            *managedButton;
}

@property (nonatomic, retain) ResolutionManaged    *document;
@end
