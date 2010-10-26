//
//  ResolutionViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 13.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ResolutionViewController.h"
#import "PerformersViewController.h"
#import "UIButton+Additions.h"
#import "TextViewWithPlaceholder.h"
#import "DocumentResolution.h"
#import "Person.h"
#import "DatePickerController.h"
#import "DataSource.h"
#import "AudioCommentController.h"
#import "CommentAudio.h"
#import "Comment.h"
#import "BlankLogoView.h"

#define RIGHT_MARGIN 24.0f
#define LEFT_MARGIN 24.0f
#define MIN_RESOLUTION_TEXT_HEIGHT 100.0f

@interface ResolutionViewController (Private)
-(void) updateContent;
-(void) updateHeight;
@end

@implementation ResolutionViewController
@synthesize document;

-(void) setDocument:(DocumentResolution *) aDocument
{
    if (document == aDocument)
    return;
    
    [document release];
    document = [aDocument retain];
    
    resolutionSwitcher.selectedSegmentIndex = 0;
    [self updateContent];
}
- (void)loadView
{
    UIImage *image = [[UIImage imageNamed: @"ResolutionBackground.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:100.0];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage: image];
    
    self.view = backgroundView;

    [backgroundView release];

    self.view.userInteractionEnabled = YES;
    self.view.autoresizesSubviews = YES;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;

    
    CGSize viewSize = self.view.frame.size;

    //visible image width
    viewSize.width = 562.0;

    
    //filter
    resolutionSwitcher = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:NSLocalizedString(@"Resolution", "Resolution"),
                                                         NSLocalizedString(@"Parent resolution", "Parent resolution"),
                                                         nil]];
    resolutionSwitcher.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [resolutionSwitcher sizeToFit];
    CGSize switcherSize = resolutionSwitcher.frame.size;
    resolutionSwitcher.frame = CGRectMake(round((viewSize.width - switcherSize.width) / 2), 44, switcherSize.width, switcherSize.height);
    
    [resolutionSwitcher addTarget:self action:@selector(showParentResolution:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview: resolutionSwitcher];
    
    //logo
    BlankLogoView *logo = [[BlankLogoView alloc] initWithFrame:CGRectZero];
    
    CGSize logoSize = logo.frame.size;
    CGRect logoFrame = CGRectMake(round((viewSize.width - logoSize.width) / 2), 83, logoSize.width, logoSize.height);
    logo.frame = logoFrame;
    
    [self.view addSubview: logo];
    
    [logo release];
    
    //performersViewController
    performersViewController = [[PerformersViewController alloc] init];
    performersViewController.view.backgroundColor = [UIColor clearColor];
    CGRect performersFrame = CGRectMake(0, logoFrame.origin.y + logoFrame.size.height+18, viewSize.width, (26 + 2)* 3); //3 rows
    performersViewController.view.frame = performersFrame;
    
    performersViewController.view.autoresizingMask = UIViewAutoresizingNone;
    
    [self.view addSubview: performersViewController.view];
    
    //deadline phrase
    UILabel *deadlinePhrase = [[UILabel alloc] initWithFrame: CGRectZero];
    deadlinePhrase.text = NSLocalizedString(@"Deadline", "Deadline");
    deadlinePhrase.textColor = [UIColor blackColor];
    deadlinePhrase.textAlignment = UITextAlignmentLeft;
    deadlinePhrase.font = [UIFont fontWithName:@"CharterC" size:18];
    deadlinePhrase.backgroundColor = [UIColor clearColor];
    
    [deadlinePhrase sizeToFit];
    
    CGSize deadlineSize = deadlinePhrase.frame.size;
    
    CGRect deadlinePhraseFrame = CGRectMake(LEFT_MARGIN, performersFrame.origin.y + performersFrame.size.height + 26, deadlineSize.width, deadlineSize.height);
    deadlinePhrase.frame = deadlinePhraseFrame;
    
    [self.view addSubview: deadlinePhrase];
    [deadlinePhrase release];
    
    //deadline button
    deadlineButton = [UIButton buttonWithBackgroundAndTitle:@" 12 August 2010 "
                                                  titleFont:[UIFont fontWithName:@"CharterC" size:18]
                                                     target:self
                                                   selector:@selector(pickDeadline:)
                                                      frame:CGRectMake(0, 0, 28, 25)
                                              addLabelWidth:YES
                                                      image:[UIImage imageNamed:@"ButtonDate.png"]
                                               imagePressed:[UIImage imageNamed:@"ButtonDate.png"]
                                               leftCapWidth:10.0f
                                              darkTextColor:YES];
    CGSize deadlineButtonSize = deadlineButton.frame.size;
    CGRect dateButtonFrame = CGRectMake(deadlinePhraseFrame.origin.x + deadlinePhraseFrame.size.width + 10, deadlinePhraseFrame.origin.y - (deadlineButtonSize.height - deadlinePhraseFrame.size.height), deadlineButtonSize.width, deadlineButtonSize.height);
    
    deadlineButton.frame = dateButtonFrame;
    
    [self.view addSubview: deadlineButton];
    
    //resolution text
    CGRect resolutionTextFrame = CGRectMake(LEFT_MARGIN, deadlinePhraseFrame.origin.y + deadlinePhraseFrame.size.height + 23, viewSize.width - RIGHT_MARGIN - LEFT_MARGIN, MIN_RESOLUTION_TEXT_HEIGHT);
    resolutionText = [[TextViewWithPlaceholder alloc] initWithFrame: resolutionTextFrame];
    
	resolutionText.textColor = [UIColor blackColor];
	resolutionText.font = [UIFont fontWithName:@"CharterC" size:16];
	resolutionText.delegate = self;
	resolutionText.backgroundColor = [UIColor clearColor];
    
    resolutionText.placeholder = NSLocalizedString(@"Enter resolution text", "Enter resolution text");
    resolutionText.placeholderColor = [UIColor lightGrayColor];
    
	resolutionText.returnKeyType = UIReturnKeyDefault;
	resolutionText.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	resolutionText.scrollEnabled = YES;
    
    resolutionText.autoresizingMask = (UIViewAutoresizingFlexibleHeight);

    [self.view addSubview: resolutionText];
    
    //author
    authorLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    authorLabel.text = @"Author";
    authorLabel.textColor = [UIColor blackColor];
    authorLabel.textAlignment = UITextAlignmentRight;
    authorLabel.font = [UIFont fontWithName:@"CharterC" size:24];
    authorLabel.backgroundColor = [UIColor clearColor];
    
    [authorLabel sizeToFit];
    
    CGSize authorSize = authorLabel.frame.size;
    
    CGRect authorFrame = CGRectMake(0, resolutionTextFrame.origin.y + resolutionTextFrame.size.height + 20, viewSize.width - RIGHT_MARGIN, authorSize.height);
    authorLabel.frame = authorFrame;
    
    authorLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview: authorLabel];
    
    //date
    dateLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    dateLabel.text = @"12 12345678910 2010"; //fixed width
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.textAlignment = UITextAlignmentCenter;
    dateLabel.font = [UIFont fontWithName:@"CharterC" size:18];
    dateLabel.backgroundColor = [UIColor clearColor];
    
    [dateLabel sizeToFit];
    
    CGSize dateSize = dateLabel.frame.size;
    
    CGRect dateFrame = CGRectMake(0, authorFrame.origin.y + authorFrame.size.height + 20, viewSize.width, dateSize.height);
    dateLabel.frame = dateFrame;
    
    dateLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview: dateLabel];
    
    UIImage *twoRowsImage = [UIImage imageNamed: @"TwoRows.png"];
    UIImageView *twoRows = [[UIImageView alloc] initWithImage: [twoRowsImage stretchableImageWithLeftCapWidth:12.0f topCapHeight:0.0f]];
    
    twoRows.userInteractionEnabled = YES;
    
    CGRect twoRowsFrame = CGRectMake(LEFT_MARGIN, dateFrame.origin.y + 35, viewSize.width - RIGHT_MARGIN - LEFT_MARGIN, twoRows.frame.size.height);

    twoRows.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

    twoRows.frame = twoRowsFrame;
    
    CGFloat oneRowHeight = round(twoRowsFrame.size.height / 2);
    
    //label Managed
    UILabel *labelManaged = [[UILabel alloc] initWithFrame: CGRectZero];
    
    labelManaged.text = NSLocalizedString(@"Managed", "Managed");
    labelManaged.textColor = [UIColor blackColor];
    labelManaged.font = [UIFont boldSystemFontOfSize: 17];
    labelManaged.backgroundColor = [UIColor clearColor];
    
    [labelManaged sizeToFit];
    
    CGRect labelManagedFrame = labelManaged.frame;
    
    labelManagedFrame.origin.x = 10.0f;
    
    labelManagedFrame.origin.y = (oneRowHeight - labelManagedFrame.size.height)/2;
    
    labelManaged.frame = labelManagedFrame;
    
    [twoRows addSubview: labelManaged];
    
    [labelManaged release];
    
    //managed button
    
    managedButton = [[UISwitch alloc] initWithFrame:CGRectZero];
    [managedButton addTarget:self 
                      action:@selector(setManaged:) 
            forControlEvents:UIControlEventValueChanged];
    [managedButton sizeToFit];
    
    CGRect managedButtonFrame = managedButton.frame;
    
    managedButtonFrame.origin.x = twoRowsFrame.size.width - managedButtonFrame.size.width - 12.0f;;
    
    managedButtonFrame.origin.y = round((oneRowHeight - labelManagedFrame.size.height) / 2);
    
    managedButton.frame = managedButtonFrame;
    
    [twoRows addSubview: managedButton];
    
    //audioCommentController
    audioCommentController = [[AudioCommentController alloc] init];
    
    CGRect audioCommentFrame = CGRectMake(0, oneRowHeight, twoRowsFrame.size.width, oneRowHeight);
    
    audioCommentController.view.frame = audioCommentFrame;
    
    [twoRows addSubview: audioCommentController.view];
 
    [self.view addSubview: twoRows];

    [twoRows release];

    [self updateContent];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [resolutionSwitcher release]; resolutionSwitcher = nil;
    
    [deadlineButton release]; deadlineButton = nil;
    
    [resolutionText release]; resolutionText = nil;
    
    [authorLabel release]; authorLabel =nil;
    
    [dateLabel release]; dateLabel = nil;

    [dateFormatter release]; dateFormatter = nil;
    
    [datePickerController release]; datePickerController = nil;
    
    [popoverController release]; popoverController = nil;
    
    [performersViewController release]; performersViewController = nil;
    
    [managedButton release]; managedButton = nil;
    
    [audioCommentController release]; audioCommentController = nil;
}


- (void)dealloc {
    [resolutionSwitcher release]; resolutionSwitcher = nil;
    
    [deadlineButton release]; deadlineButton = nil;
    
    [resolutionText release]; resolutionText = nil;
    
    [authorLabel release]; authorLabel =nil;
    
    [dateLabel release]; dateLabel = nil;
    
    [dateFormatter release]; dateFormatter = nil;
    
    [datePickerController release]; datePickerController = nil;
    
    [popoverController release]; popoverController = nil;
    
    [performersViewController release]; performersViewController = nil;
    
    [managedButton release]; managedButton = nil;
    
    [audioCommentController release]; audioCommentController = nil;
    
    self.document = nil;
    [super dealloc];

}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self updateHeight];
    
    document.text = resolutionText.text;
    
    [[DataSource sharedDataSource] commit];
    return YES;
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)pc
{
    [[DataSource sharedDataSource] commit];
}

#pragma Private

-(void) updateContent
{
    DocumentResolutionAbstract *resolution  = document;
    DocumentResolutionParent *parentResolution = document.parentResolution;
    
    resolutionSwitcher.hidden = (parentResolution == nil);
    
    if (resolutionSwitcher.selectedSegmentIndex == 0) //resolution
    {
        deadlineButton.userInteractionEnabled = YES;
    }
    else //parent resolution
    {
        resolution = (DocumentResolutionAbstract *)parentResolution;
        deadlineButton.userInteractionEnabled = NO;
    }
        
    authorLabel.text = resolution.author;
    
    resolutionText.text = resolution.text;
    
    [resolutionText textChanged:nil];
    
    dateLabel.text = [dateFormatter stringFromDate: resolution.registrationDate];
    
    NSString *label;
    if (resolution.deadline)
        label = [NSString stringWithFormat:@"   %@   ", [dateFormatter stringFromDate:resolution.deadline]];
    else
        label = nil;

    [deadlineButton setTitle:label forState:UIControlStateNormal];
    
    [deadlineButton sizeToFit];
    
    performersViewController.document = resolution;
    
    audioCommentController.file = document.comment.audio;
    
    managedButton.on = resolution.isManagedValue;
    
    [self updateHeight];
}

- (void) showParentResolution:(id) sender
{
    [self updateContent];
}

-(void) updateHeight;
{
    CGRect textViewFrame = resolutionText.frame;
    UILabel *label = [[UILabel alloc] initWithFrame: textViewFrame];
    label.numberOfLines = 0;
    label.font = resolutionText.font;
    label.text = resolutionText.text;
    [label sizeToFit];
    CGFloat heightDelta = label.frame.size.height - textViewFrame.size.height;
    [label release];
    
    CGRect viewFrame = self.view.frame;
    if (MIN_RESOLUTION_TEXT_HEIGHT < (textViewFrame.size.height + heightDelta))
    {
        viewFrame.size.height += heightDelta;
        CGFloat maxHeight = self.view.superview.frame.size.height + viewFrame.origin.y;
        if (viewFrame.size.height > maxHeight)
            viewFrame.size.height = maxHeight;
        self.view.frame = viewFrame;
        [resolutionText scrollRangeToVisible: NSMakeRange(0, 1)];
    }
    else
    {
        viewFrame.size.height -= textViewFrame.size.height - MIN_RESOLUTION_TEXT_HEIGHT;
        self.view.frame = viewFrame;
    }
    if ([resolutionText.text length])
        [resolutionText scrollRangeToVisible: NSMakeRange(0, 1)];
    
}
#pragma mark -
#pragma mark actions
-(void) pickDeadline:(id) sender
{
    if (!datePickerController)
    {
        datePickerController = [[DatePickerController alloc] init];
        datePickerController.target = self;
        datePickerController.selector = @selector(setDeadLine:);
    }
    
    if (!popoverController)
    {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:datePickerController];
        popoverController.delegate = self;
    }
    
    datePickerController.date = document.deadline;
    UIView *button = (UIView *)sender;
    CGRect targetRect = button.frame;
	[popoverController presentPopoverFromRect: targetRect inView:[button superview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void) setDeadLine:(id) sender
{
    NSString *label;
    
    NSDate *deadline = datePickerController.date;

    document.deadline = deadline;
    
    if (deadline)
        label = [NSString stringWithFormat:@"   %@   ", [dateFormatter stringFromDate:deadline]];
    else
        label = nil;
    
    [deadlineButton setTitle:label forState:UIControlStateNormal];
    [deadlineButton sizeToFit];
}

-(void) setManaged:(id) sender
{
    document.isManagedValue = managedButton.on;

    [[DataSource sharedDataSource] commit];
}

@end