//
//  ResolutionViewController.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 13.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ResolutionViewController.h"
#import "PerformersViewController.h"
#import "UIButton+Additions.h"
#import "SSTextView.h"
#import "DocumentResolution.h"
#import "Person.h"
#import "DatePickerController.h"
#import "DataSource.h"
#import "AudioCommentController.h"
#import "CommentAudio.h"
#import "BlankLogoView.h"
#import "ResolutionContentView.h"
#import "DocumentResolutionParent.h"

#define RIGHT_MARGIN 30.0f
#define LEFT_MARGIN 30.0f
//plus shadow 26
#define BOTTOM_MARGIN 54.0f
#define MIN_CONTENT_HEIGHT 460.0f

@interface ResolutionViewController (Private)
-(void) updateContent;
@end

@implementation ResolutionViewController
@synthesize document;

-(void) setDocument:(DocumentResolution *) aDocument
{
    if (document != aDocument)
    {
        [document release];
        document = [aDocument retain];
    }
    
    resolutionSwitcher.selectedSegmentIndex = 0;
    [self updateContent];
}
- (void)loadView
{
    UIImage *image = [[UIImage imageNamed: @"BlankBackground.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:100.0];
    
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

    
    CGSize viewSize = self.view.bounds.size;

    //visible image width
    viewSize.width = 562.0;

    CGRect contentViewFrame = CGRectMake(0, 44, viewSize.width, MIN_CONTENT_HEIGHT);
	
	fullContentViewSize = contentViewFrame.size;
    
    contentView = [[ResolutionContentView alloc] initWithFrame: contentViewFrame];
    contentView.contentInset = UIEdgeInsetsMake(0, LEFT_MARGIN, 0, RIGHT_MARGIN);

    
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
    
    performersViewController.target = [DataSource sharedDataSource];
    performersViewController.action = @selector(commit);
    
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
    resolutionText = [[SSTextView alloc] initWithFrame: CGRectZero];
    
	resolutionText.textColor = [UIColor blackColor];
	resolutionText.font = [UIFont fontWithName:@"CharterC" size:16];
	resolutionText.delegate = self;
	resolutionText.backgroundColor = [UIColor clearColor];
    
    resolutionText.placeholder = NSLocalizedString(@"Enter resolution text", "Enter resolution text");
    resolutionText.placeholderColor = [UIColor lightGrayColor];
    
	resolutionText.returnKeyType = UIReturnKeyDefault;
	resolutionText.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	resolutionText.scrollEnabled = NO;

    //remove right-left margins
    resolutionText.contentInset = UIEdgeInsetsMake(-4,-8,0,0);

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
    twoRows = [[UIImageView alloc] initWithImage: [twoRowsImage stretchableImageWithLeftCapWidth:12.0f topCapHeight:0.0f]];
    
    twoRows.userInteractionEnabled = YES;
    
    CGRect twoRowsFrame = CGRectMake(LEFT_MARGIN, viewSize.height - twoRows.frame.size.height - BOTTOM_MARGIN, viewSize.width - RIGHT_MARGIN - LEFT_MARGIN, twoRows.frame.size.height);

    twoRows.frame = twoRowsFrame;
    
    CGFloat oneRowHeight = round(twoRowsFrame.size.height / 2);
    
	CGRect managedViewFrame = CGRectMake(10.f, 0, twoRowsFrame.size.width - 10.0f - 10.f, oneRowHeight - 6);
	
	managedView = [[UIView alloc] initWithFrame:managedViewFrame];
	
	[twoRows addSubview:managedView];
	
    //label Managed
    UILabel *labelManaged = [[UILabel alloc] initWithFrame: CGRectZero];
    
    labelManaged.text = NSLocalizedString(@"Managed", "Managed");
    labelManaged.textColor = [UIColor blackColor];
    labelManaged.font = [UIFont boldSystemFontOfSize: 17];
    labelManaged.backgroundColor = [UIColor clearColor];
    
    [labelManaged sizeToFit];
    
    CGRect labelManagedFrame = labelManaged.frame;
    
    labelManagedFrame.origin.x = 0.f;
    
    labelManagedFrame.origin.y = round((managedViewFrame.size.height - labelManagedFrame.size.height) / 2);
    
    labelManaged.frame = labelManagedFrame;
    
    [managedView addSubview: labelManaged];
    
    [labelManaged release];
    
    //managed button
    
    managedButton = [[UISwitch alloc] initWithFrame:CGRectZero];
    [managedButton addTarget:self 
                      action:@selector(setManaged:) 
            forControlEvents:UIControlEventValueChanged];
    [managedButton sizeToFit];
    
    CGRect managedButtonFrame = managedButton.frame;
    
    managedButtonFrame.origin.x = managedViewFrame.size.width - managedButtonFrame.size.width;
    
    managedButtonFrame.origin.y = round((managedViewFrame.size.height - labelManagedFrame.size.height) / 2);
    
    managedButton.frame = managedButtonFrame;
    
    [managedView addSubview: managedButton];
	
    //audioCommentController
    audioCommentController = [[AudioCommentController alloc] init];
    
    CGRect audioCommentFrame = CGRectMake(0, oneRowHeight, twoRowsFrame.size.width, oneRowHeight);
    
    audioCommentController.view.frame = audioCommentFrame;
    
    [twoRows addSubview: audioCommentController.view];
 
    [self.view addSubview: twoRows];
	
	UIImage *oneRowImage = [UIImage imageNamed: @"OneRow.png"];
    oneRow = [[UIImageView alloc] initWithImage: [oneRowImage stretchableImageWithLeftCapWidth:12.0f topCapHeight:0.0f]];
    
    oneRow.userInteractionEnabled = YES;
    
    CGRect oneRowFrame = CGRectMake(LEFT_MARGIN, viewSize.height - oneRow.frame.size.height - BOTTOM_MARGIN, viewSize.width - RIGHT_MARGIN - LEFT_MARGIN, oneRow.frame.size.height);
	
    oneRow.frame = oneRowFrame;
	
	[self.view addSubview:oneRow];

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
	
	[twoRows release]; twoRows = nil;
	
	[oneRow release]; oneRow = nil;
	
	[managedView release]; managedView = nil;
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
	
	[twoRows release]; twoRows = nil;

	[oneRow release]; oneRow = nil;
	
	[managedView release]; managedView = nil;
	
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
    resolutionSwitcher.hidden = (document.parentResolution == nil);
    
    if (resolutionSwitcher.selectedSegmentIndex == 0) //resolution
    {
		deadlineButton.userInteractionEnabled = YES;

        DocumentResolution *resolution  = document;

        authorLabel.text = resolution.author;
        
        resolutionText.text = resolution.text;
        
#warning obsoleted in iOS 4
            //due to bug in 3.2 with editable property (showing keybouar), use this trick
            //http://stackoverflow.com/questions/2133335/iphone-uitextview-which-is-disabled-becomes-first-responder-when-re-enabled
        resolutionText.userInteractionEnabled = resolution.isEditableValue;
        
        dateLabel.text = [dateFormatter stringFromDate: (resolution.date?resolution.date:[NSDate date])];

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
        
        [performersViewController setPerformers:resolution.performersOrdered isEditable:resolution.isEditableValue];
        
        audioCommentController.file = resolution.audio;
        
        managedButton.on = resolution.isManagedValue;
        
        managedButton.enabled = resolution.isEditableValue;

		if (resolution.isEditableValue || (!resolution.isEditableValue && audioCommentController.isExists))
		{
			if (managedView.superview != twoRows)
			{
				[managedView removeFromSuperview];
		
				[twoRows addSubview:managedView];
		
				oneRow.hidden = YES;
		
				twoRows.hidden = NO;

				CGRect contentViewFrame = contentView.frame;
		
				contentViewFrame.size.height = fullContentViewSize.height;
		
				contentView.frame = contentViewFrame;
			}
		}
		else
		{
			if (managedView.superview != oneRow) 
			{
				[managedView removeFromSuperview];
				
				[oneRow addSubview:managedView];
				
				oneRow.hidden = NO;
				
				twoRows.hidden = YES;
				
				CGRect contentViewFrame = contentView.frame;
				
				contentViewFrame.size.height = fullContentViewSize.height + oneRow.frame.size.height;
				
				contentView.frame = contentViewFrame;
				
			}
		}
}
    else //parent resolution
    {
        deadlineButton.userInteractionEnabled = NO;
        
        resolutionText.userInteractionEnabled = NO;

        DocumentResolutionParent *parentResolution = document.parentResolution;

        authorLabel.text = parentResolution.author;
        
        resolutionText.text = parentResolution.text;
        
        dateLabel.text = [dateFormatter stringFromDate: parentResolution.date];

        NSString *label;
        if (parentResolution.deadline)
            label = [NSString stringWithFormat:@"   %@   ", [dateFormatter stringFromDate:parentResolution.deadline]];
        else
            label = [NSString stringWithFormat:@"   %@   ", NSLocalizedString(@"Not set", "resolution->deadline->Not set")];
        
        deadlineLabel.text = label;
        [deadlineLabel sizeToFit];
        deadlineLabel.hidden = NO;
        deadlineButton.hidden = YES;
        
        [performersViewController setPerformers:nil isEditable:NO];
        
        audioCommentController.file = nil;
        
        managedButton.on = parentResolution.isManagedValue;
        
        managedButton.enabled = NO;
		
		if (managedView.superview != oneRow) 
		{
			[managedView removeFromSuperview];
			
			[oneRow addSubview:managedView];

			oneRow.hidden = NO;
			
			twoRows.hidden = YES;
			
			CGRect contentViewFrame = contentView.frame;
			
			contentViewFrame.size.height = fullContentViewSize.height + oneRow.frame.size.height;
			
			contentView.frame = contentViewFrame;
			
		}
    }

    [contentView setNeedsLayout];
    
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