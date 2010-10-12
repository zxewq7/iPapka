//
//  SignatureCommentViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 03.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "SignatureCommentViewController.h"
#import "TextViewWithPlaceholder.h"
#import "DocumentSignature.h"
#import "DataSource.h"
#import "AudioCommentController.h"
#import "Person.h"
#import "SignatureAudio.h"

#define RIGHT_MARGIN 24.0f
#define LEFT_MARGIN 24.0f
#define MIN_COMMENT_TEXT_HEIGHT 300.0f

@interface SignatureCommentViewController (Private)
-(void) updateContent;
-(void) updateHeight;
@end

@implementation SignatureCommentViewController
@synthesize document;

-(void) setDocument:(DocumentSignature *) aDocument
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
    
    //logo
    UIImageView *logo = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"ResolutionLogo.png"]];
    
    CGSize logoSize = logo.frame.size;
    CGRect logoFrame = CGRectMake((viewSize.width - logoSize.width)/2, 83, logoSize.width, logoSize.height);
    logo.frame = logoFrame;
    
    [self.view addSubview: logo];
    
    [logo release];
    
    //resolution text
    CGRect commentTextFrame = CGRectMake(LEFT_MARGIN, logoFrame.origin.y + logoFrame.size.height + 18, viewSize.width - RIGHT_MARGIN - LEFT_MARGIN, MIN_COMMENT_TEXT_HEIGHT);
    commentText = [[TextViewWithPlaceholder alloc] initWithFrame: commentTextFrame];
    
	commentText.textColor = [UIColor blackColor];
	commentText.font = [UIFont fontWithName:@"CharterC" size:16];
	commentText.delegate = self;
	commentText.backgroundColor = [UIColor clearColor];
    
    commentText.placeholder = NSLocalizedString(@"Enter resolution text", "Enter resolution text");
    commentText.placeholderColor = [UIColor lightGrayColor];
    
	commentText.returnKeyType = UIReturnKeyDefault;
	commentText.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	commentText.scrollEnabled = YES;
    
    commentText.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
    
    [self.view addSubview: commentText];
    
    //author
    authorLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    authorLabel.text = @"Author";
    authorLabel.textColor = [UIColor blackColor];
    authorLabel.textAlignment = UITextAlignmentRight;
    authorLabel.font = [UIFont fontWithName:@"CharterC" size:24];
    authorLabel.backgroundColor = [UIColor clearColor];
    
    [authorLabel sizeToFit];
    
    CGSize authorSize = authorLabel.frame.size;
    
    CGRect authorFrame = CGRectMake(0, commentTextFrame.origin.y + commentTextFrame.size.height + 20, viewSize.width - RIGHT_MARGIN, authorSize.height);
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
    
    UIImage *oneRowImage = [UIImage imageNamed: @"OneRow.png"];
    UIImageView *oneRow = [[UIImageView alloc] initWithImage: [oneRowImage stretchableImageWithLeftCapWidth:12.0f topCapHeight:0.0f]];
    
    oneRow.userInteractionEnabled = YES;
    
    CGRect oneRowFrame = CGRectMake(LEFT_MARGIN, dateFrame.origin.y + 35, viewSize.width - RIGHT_MARGIN - LEFT_MARGIN, oneRow .frame.size.height);
    
    oneRow.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
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
}


- (void)dealloc {
    [commentText release]; commentText = nil;
    
    [authorLabel release]; authorLabel =nil;
    
    [dateLabel release]; dateLabel = nil;
    
    [dateFormatter release]; dateFormatter = nil;
    
    [audioCommentController release]; audioCommentController = nil;
    
    self.document = nil;
    [super dealloc];
    
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self updateHeight];
    
    document.comment = commentText.text;
    
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
    authorLabel.text = document.author.fullName;
    
    commentText.text = document.comment;
    
    [commentText textChanged:nil];
    
    dateLabel.text = [dateFormatter stringFromDate: document.dateModified];
    
    audioCommentController.file = document.audioComment;

    [self updateHeight];
}

- (void) showParentResolution:(id) sender
{
    [self updateContent];
}

-(void) updateHeight;
{
    CGRect textViewFrame = commentText.frame;
    UILabel *label = [[UILabel alloc] initWithFrame: textViewFrame];
    label.numberOfLines = 0;
    label.font = commentText.font;
    label.text = commentText.text;
    [label sizeToFit];
    CGFloat heightDelta = label.frame.size.height - textViewFrame.size.height;
    [label release];
    
    CGRect viewFrame = self.view.frame;
    if (MIN_COMMENT_TEXT_HEIGHT < (textViewFrame.size.height + heightDelta))
    {
        viewFrame.size.height += heightDelta;
        CGFloat maxHeight = self.view.superview.frame.size.height + viewFrame.origin.y;
        if (viewFrame.size.height > maxHeight)
            viewFrame.size.height = maxHeight;
        self.view.frame = viewFrame;
    }
    else
    {
        viewFrame.size.height -= textViewFrame.size.height - MIN_COMMENT_TEXT_HEIGHT;
        self.view.frame = viewFrame;
    }
    if ([commentText.text length])
        [commentText scrollRangeToVisible: NSMakeRange(0, 1)];
}
@end