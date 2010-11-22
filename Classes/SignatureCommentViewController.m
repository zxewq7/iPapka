//
//  SignatureCommentViewController.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 03.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "SignatureCommentViewController.h"
#import "SSTextView.h"
#import "DocumentSignature.h"
#import "DataSource.h"
#import "AudioCommentController.h"
#import "Person.h"
#import "CommentAudio.h"
#import "BlankLogoView.h"
#import "SignatureContentView.h"

#define RIGHT_MARGIN 30.0f
#define LEFT_MARGIN 30.0f
//plus shadow 26
#define BOTTOM_MARGIN 56.0f
#define MIN_CONTENT_HEIGHT 460.0f

@interface SignatureCommentViewController (Private)
-(void) updateContent;
-(void) updateHeight;
@end

@implementation SignatureCommentViewController
@synthesize document;

-(void) setDocument:(DocumentSignature *) aDocument
{
    if (document != aDocument)
    {
        [document release];
        document = [aDocument retain];
    }
    
    [self updateContent];
}
- (void)loadView
{
    UIImage *image = [[UIImage imageNamed: @"BlankBackground.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:100.0];
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

    CGRect contentViewFrame = CGRectMake(LEFT_MARGIN, 83, viewSize.width - LEFT_MARGIN - RIGHT_MARGIN, MIN_CONTENT_HEIGHT);
    
    contentView = [[SignatureContentView alloc] initWithFrame: contentViewFrame];
    
    //logo
    BlankLogoView *logo = [[BlankLogoView alloc] initWithFrame:CGRectZero];
    
    [contentView addSubview: logo withTag:SignatureContentViewLogo];
    
    [logo release];
    
    //comment text
    commentText = [[SSTextView alloc] initWithFrame: CGRectZero];
    
	commentText.textColor = [UIColor blackColor];
	commentText.font = [UIFont fontWithName:@"CharterC" size:16];
	commentText.delegate = self;
	commentText.backgroundColor = [UIColor clearColor];
    
    commentText.placeholder = NSLocalizedString(@"Enter resolution text", "Enter resolution text");
    commentText.placeholderColor = [UIColor lightGrayColor];
    
	commentText.returnKeyType = UIReturnKeyDefault;
	commentText.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	commentText.scrollEnabled = NO;
    
    [contentView addSubview:commentText withTag:SignatureContentViewCommentText];
    
    //author
    authorLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    authorLabel.text = @"Author";
    authorLabel.textColor = [UIColor blackColor];
    authorLabel.textAlignment = UITextAlignmentRight;
    authorLabel.font = [UIFont fontWithName:@"CharterC" size:24];
    authorLabel.backgroundColor = [UIColor clearColor];
    
    [authorLabel sizeToFit];
    
    [contentView addSubview: authorLabel withTag:SignatureContentViewAuthorLabel];
    
    //date
    dateLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    dateLabel.text = @"12 12345678910 2010"; //fixed width
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.textAlignment = UITextAlignmentCenter;
    dateLabel.font = [UIFont fontWithName:@"CharterC" size:18];
    dateLabel.backgroundColor = [UIColor clearColor];
    
    [dateLabel sizeToFit];
    
    [contentView addSubview: dateLabel withTag:SignatureContentViewDateLabel];
    
    [self.view addSubview:contentView];
    
    UIImage *oneRowImage = [UIImage imageNamed: @"OneRow.png"];
    UIImageView *oneRow = [[UIImageView alloc] initWithImage: [oneRowImage stretchableImageWithLeftCapWidth:12.0f topCapHeight:0.0f]];
    
    oneRow.userInteractionEnabled = YES;
    
    CGRect oneRowFrame = CGRectMake(LEFT_MARGIN, viewSize.height - oneRow.frame.size.height - BOTTOM_MARGIN, viewSize.width - RIGHT_MARGIN - LEFT_MARGIN, oneRow.frame.size.height);

    oneRow.frame = oneRowFrame;

    [self.view addSubview: oneRow];

    //audioCommentController
    audioCommentController = [[AudioCommentController alloc] init];
    
    CGRect audioCommentFrame = CGRectMake(0, 0, oneRowFrame.size.width, oneRowFrame.size.height);
    
    audioCommentController.view.frame = audioCommentFrame;
    
    [oneRow addSubview: audioCommentController.view];
    
    [oneRow release];
    
    [self updateContent];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [commentText release]; commentText = nil;
    
    [authorLabel release]; authorLabel =nil;
    
    [dateLabel release]; dateLabel = nil;
    
    [dateFormatter release]; dateFormatter = nil;
    
    [audioCommentController release]; audioCommentController = nil;
    
    [contentView release]; contentView = nil;
}


- (void)dealloc {
    [commentText release]; commentText = nil;
    
    [authorLabel release]; authorLabel =nil;
    
    [dateLabel release]; dateLabel = nil;
    
    [dateFormatter release]; dateFormatter = nil;
    
    [audioCommentController release]; audioCommentController = nil;
    
    [contentView release]; contentView = nil;
    
    self.document = nil;
    [super dealloc];
    
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([commentText.text length])
        [commentText scrollRangeToVisible: NSMakeRange(0, 1)];

    document.text = commentText.text;
    
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
    authorLabel.text = document.author;
    
    commentText.text = document.text;

#warning obsoleted in iOS 4
    //due to bug in 3.2 with editable property (showing keybouar), use this trick
    //http://stackoverflow.com/questions/2133335/iphone-uitextview-which-is-disabled-becomes-first-responder-when-re-enabled
    commentText.userInteractionEnabled = document.isEditableValue;
    
    dateLabel.text = [dateFormatter stringFromDate: document.date];
    
    audioCommentController.file = document.audio;
    
    [contentView setNeedsLayout];
    
    //scroll content to top
    [contentView scrollRectToVisible:CGRectZero animated:NO];
}

- (void) showParentResolution:(id) sender
{
    [self updateContent];
}
@end