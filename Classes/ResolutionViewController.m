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
#import "BlankLogoView.h"
#import "ResolutionContentView.h"

#define RIGHT_MARGIN 24.0f
#define LEFT_MARGIN 24.0f
#define MIN_CONTENT_HEIGHT 460.0f

@interface ResolutionViewController (Private)
-(void) updateContent;
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
    
    minSize = image.size;
    
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

    CGRect contentViewFrame = CGRectMake(0, 44, viewSize.width, MIN_CONTENT_HEIGHT);
    
    contentView = [[ResolutionContentView alloc] initWithFrame: contentViewFrame];
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);

    
    //filter
    resolutionSwitcher = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:NSLocalizedString(@"Resolution", "Resolution"),
                                                         NSLocalizedString(@"Parent resolution", "Parent resolution"),
                                                         nil]];
    resolutionSwitcher.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [resolutionSwitcher sizeToFit];
    
    [resolutionSwitcher addTarget:self action:@selector(showParentResolution:) forControlEvents:UIControlEventValueChanged];
    
    [contentView addSubview: resolutionSwitcher withTag:ResolutionContentViewSwitcher];
    
    //logo
    BlankLogoView *logo = [[BlankLogoView alloc] initWithFrame:CGRectZero];
    
    [contentView addSubview: logo withTag:ResolutionContentViewLogo];
    
    [logo release];
    
    //performersViewController
    performersViewController = [[PerformersViewController alloc] init];
    
    [contentView addSubview: performersViewController.view withTag:ResolutionContentViewPerformers];
    
    //deadline phrase
    UILabel *deadlinePhrase = [[UILabel alloc] initWithFrame: CGRectZero];
    deadlinePhrase.text = NSLocalizedString(@"Deadline", "Deadline");
    deadlinePhrase.textColor = [UIColor blackColor];
    deadlinePhrase.textAlignment = UITextAlignmentLeft;
    deadlinePhrase.font = [UIFont fontWithName:@"CharterC" size:18];
    deadlinePhrase.backgroundColor = [UIColor clearColor];
    
    [deadlinePhrase sizeToFit];
    
    [contentView addSubview: deadlinePhrase withTag:ResolutionContentViewDeadlinePhrase];
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
    
    [contentView addSubview: deadlineButton withTag:ResolutionContentViewDeadlineButton];
    
    //deadLine label
    deadlineLabel = [[UILabel alloc] initWithFrame:CGRectZero];

    deadlineLabel.font = deadlineButton.titleLabel.font;
    
    deadlineLabel.text = @" 12 August 2010 ";

    deadlineLabel.backgroundColor = [UIColor clearColor];

    [deadlineLabel sizeToFit];
    
    
    [contentView addSubview: deadlineLabel withTag:ResolutionContentViewDeadlineLabel];
    
    
    //resolution text
    resolutionText = [[TextViewWithPlaceholder alloc] initWithFrame: CGRectZero];
    
	resolutionText.textColor = [UIColor blackColor];
	resolutionText.font = [UIFont fontWithName:@"CharterC" size:16];
	resolutionText.delegate = self;
	resolutionText.backgroundColor = [UIColor clearColor];
    
    resolutionText.placeholder = NSLocalizedString(@"Enter resolution text", "Enter resolution text");
    resolutionText.placeholderColor = [UIColor lightGrayColor];
    
	resolutionText.returnKeyType = UIReturnKeyDefault;
	resolutionText.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	resolutionText.scrollEnabled = NO;
    
    [contentView addSubview: resolutionText withTag:ResolutionContentViewResolutionText];
    
    //author
    authorLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    authorLabel.text = @"Author";
    authorLabel.textColor = [UIColor blackColor];
    authorLabel.textAlignment = UITextAlignmentRight;
    authorLabel.font = [UIFont fontWithName:@"CharterC" size:24];
    authorLabel.backgroundColor = [UIColor clearColor];
    
    [authorLabel sizeToFit];
    
    [contentView addSubview: authorLabel withTag:ResolutionContentViewAuthorLabel];
    
    //date
    dateLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    dateLabel.text = @"12 12345678910 2010"; //fixed width
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.textAlignment = UITextAlignmentCenter;
    dateLabel.font = [UIFont fontWithName:@"CharterC" size:18];
    dateLabel.backgroundColor = [UIColor clearColor];
    
    [dateLabel sizeToFit];
    
    [contentView addSubview: dateLabel withTag:ResolutionContentViewDateLabel];

    [self.view addSubview:contentView];

    UIImage *twoRowsImage = [UIImage imageNamed: @"TwoRows.png"];
    UIImageView *twoRows = [[UIImageView alloc] initWithImage: [twoRowsImage stretchableImageWithLeftCapWidth:12.0f topCapHeight:0.0f]];
    
    twoRows.userInteractionEnabled = YES;
    
    CGRect twoRowsFrame = CGRectMake(LEFT_MARGIN, contentViewFrame.origin.y + contentViewFrame.size.height + 20, viewSize.width - RIGHT_MARGIN - LEFT_MARGIN, twoRows.frame.size.height);

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
    
    [deadlineLabel release]; deadlineLabel = nil;
    
    [contentView release]; contentView = nil;
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
    
    [deadlineLabel release]; deadlineLabel = nil;
    
    [audioCommentController release]; audioCommentController = nil;
    
    self.document = nil;
    
    [contentView release]; contentView = nil;
    [super dealloc];

}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([resolutionText.text length])
        [resolutionText scrollRangeToVisible: NSMakeRange(0, 1)];
    
    document.text = resolutionText.text;
    
    [[DataSource sharedDataSource] commit];
    
    [contentView setNeedsLayout];
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

#warning obsoleted in iOS 4
    //due to bug in 3.2 with editable property (showing keybouar), use this trick
    //http://stackoverflow.com/questions/2133335/iphone-uitextview-which-is-disabled-becomes-first-responder-when-re-enabled
    resolutionText.userInteractionEnabled = resolution.isEditable;

    
    dateLabel.text = [dateFormatter stringFromDate: resolution.registrationDate];
    
    NSString *label;
    if (resolution.deadline)
        label = [NSString stringWithFormat:@"   %@   ", [dateFormatter stringFromDate:resolution.deadline]];
    else
        label = [NSString stringWithFormat:@"   %@   ", NSLocalizedString(@"Not set", "resolution->deadline->Not set")];

    if (resolution.isEditable)
    {
        [deadlineButton setTitle:label forState:UIControlStateNormal];
        [deadlineButton sizeToFit];
        deadlineButton.hidden = NO;
        
        deadlineLabel.hidden = YES;
    }
    else
    {
        deadlineLabel.text = label;
        [deadlineLabel sizeToFit];
        deadlineLabel.hidden = NO;
        
        deadlineButton.hidden = YES;
    }
    performersViewController.document = resolution;
    
    audioCommentController.file = resolution.audio;
    
    managedButton.on = resolution.isManagedValue;
    
    //scroll content to top
    [contentView scrollRectToVisible:CGRectZero animated:NO];
}

- (void) showParentResolution:(id) sender
{
    [self updateContent];
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