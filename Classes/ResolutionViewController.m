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
#import "Resolution.h"
#import "ResolutionManaged.h"
#import "DatePickerController.h"

#define RIGHT_MARGIN 24.0f
#define LEFT_MARGIN 24.0f
#define MIN_RESOLUTION_TEXT_HEIGHT 100.0f

@interface ResolutionViewController (Private)
-(void) updateContent;
-(void) updateHeight;
@end

@implementation ResolutionViewController
@synthesize document;

-(void) setDocument:(ResolutionManaged *) aDocument
{
    if (document == aDocument)
    return;
    
    [document release];
    document = [aDocument retain];
    
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
    resolutionSwitcher.frame = CGRectMake((viewSize.width - switcherSize.width)/2, 44, switcherSize.width, switcherSize.height);
    
    [resolutionSwitcher addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    
    resolutionSwitcher.selectedSegmentIndex = 0;
    
    [self.view addSubview: resolutionSwitcher];
    
    logo = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"ResolutionLogo.png"]];
    
    CGSize logoSize = logo.frame.size;
    CGRect logFrame = CGRectMake((viewSize.width - logoSize.width)/2, 83, logoSize.width, logoSize.height);
    logo.frame = logFrame;
    
    [self.view addSubview: logo];
    
    performersViewController = [[PerformersViewController alloc] init];
    performersViewController.view.backgroundColor = [UIColor redColor];
    CGRect performersFrame = CGRectMake(0, logFrame.origin.y + logFrame.size.height+18, viewSize.width, (26 + 2)* 3); //3 rows
    performersViewController.view.frame = performersFrame;
    
    performersViewController.view.autoresizingMask = UIViewAutoresizingNone;
    
    [self.view addSubview: performersViewController.view];
    
    //deadline phrase
    UILabel *deadlinePhrase = [[UILabel alloc] initWithFrame: CGRectZero];
    deadlinePhrase.text = NSLocalizedString(@"Perform resolution till date", "Perform resolution till date");
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
    
    ((TextViewWithPlaceholder *)resolutionText).placeholder = NSLocalizedString(@"Enter resolution text", "Enter resolution text");
    ((TextViewWithPlaceholder *)resolutionText).placeholderColor = [UIColor lightGrayColor];
    
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
    
    [self updateContent];
    [self updateHeight];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [resolutionSwitcher release];
    resolutionSwitcher = nil;
    
    [logo release];
    logo = nil;
    
    [deadlineButton release];
    deadlineButton = nil;
    
    [resolutionText release];
    resolutionText = nil;
    
    [authorLabel release];
    authorLabel =nil;
    
    [dateLabel release];
    dateLabel = nil;

    [dateFormatter release];
    dateFormatter = nil;
    
    [datePickerController release];
    datePickerController = nil;
    
    [popoverController release];
    popoverController = nil;
    
    [performersViewController release];
    performersViewController = nil;
}


- (void)dealloc {
    [resolutionSwitcher release];
    resolutionSwitcher = nil;

    [logo release];
    logo = nil;
    
    [deadlineButton release];
    deadlineButton = nil;

    [resolutionText release];
    resolutionText = nil;

    [authorLabel release];
    authorLabel =nil;
    
    [dateLabel release];
    dateLabel = nil;

    self.document = nil;
    [super dealloc];
    
    [dateFormatter release];
    dateFormatter = nil;
    
    [datePickerController release];
    datePickerController = nil;
    
    [popoverController release];
    popoverController = nil;
    
    [performersViewController release];
    performersViewController = nil;
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self updateHeight];
    
    Resolution *resolution = (Resolution *)document.document;
    resolution.text = resolutionText.text;
    
    [self.document saveDocument];
    return YES;
}
#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)pc
{
    if (popoverController == pc)
        [self.document saveDocument];
}

#pragma Privare

-(void) updateContent
{
    Resolution *resolution = (Resolution *)document.document;
    authorLabel.text = document.author;
    resolutionText.text = resolution.text;
    dateLabel.text = [dateFormatter stringFromDate: document.dateModified];
    
    NSString *label = (resolution.deadline?[dateFormatter stringFromDate: resolution.deadline]:nil);
    [deadlineButton setTitle:label forState:UIControlStateNormal];
    performersViewController.document = document;
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
    
    Resolution *resolution = (Resolution *)document.document;
    datePickerController.date = resolution.deadline;
    UIView *button = (UIView *)sender;
    CGRect targetRect = button.bounds;
	[popoverController presentPopoverFromRect: targetRect inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void) setDeadLine:(id) sender
{
    NSString *label;
    
    NSDate *deadline = datePickerController.date;

    Resolution *resolution = (Resolution *)document.document;
    resolution.deadline = deadline;
    
    if (deadline)
        label = [dateFormatter stringFromDate:deadline];
    else
        label = nil;
    
    [deadlineButton setTitle:label forState:UIControlStateNormal];
}
@end