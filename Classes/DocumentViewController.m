    //
    //  DocumentViewController.m
    //  Meester
    //
    //  Created by Vladimir Solomenchuk on 10.08.10.
    //  Copyright 2010 __MyCompanyName__. All rights reserved.
    //

#import "DocumentViewController.h"
#import "DocumentManaged.h"
#import "DataSource.h"
#import "Document.h"
#import "Attachment.h"
#import "ImageScrollView.h"
#import "AttachmentsViewController.h"
#import "DocumentInfoViewController.h"

#define kAttachmentLabelTag 1

@interface DocumentViewController(Private)
- (void) createToolbar;
- (UIButton *) createButton:(NSString *) aNormalImageName selectedState:(NSString *) aSelectedImageName action:(SEL) anAction;
@end
@implementation DocumentViewController

#pragma mark -
#pragma mark Properties
@synthesize navigationBar, document;


-(void) setDocument:(DocumentManaged *) aDocument
{
    if (document == aDocument)
        return;
    [document release];
    document = [aDocument retain];
    
    if (![document.isRead boolValue])
        document.isRead = [NSNumber numberWithBool:YES];
    [[DataSource sharedDataSource] commit];

    infoViewController.document = document;
    
    NSArray *attachments = document.document.attachments;
    NSUInteger numberOfAttachments = [attachments count];
    if (numberOfAttachments) 
    {
        Attachment *firstAttachment = [attachments objectAtIndex:0];
        attachmentsViewController.attachment = firstAttachment;
        NSString *attachmentTitle = [NSString stringWithFormat:@"%d %@ %d", 1, NSLocalizedString(@"of", "of"), numberOfAttachments];
        [attachmentButton setTitle:attachmentTitle forState:UIControlStateNormal];
        attachmentButton.enabled = YES;
    }
    else
        attachmentButton.enabled = NO;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([attachmentsViewController respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]) 
        [attachmentsViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
         
    if ([infoViewController respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]) 
         [infoViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect viewRect = self.view.bounds;
    CGRect toolbarRect = self.navigationBar.bounds;
    
    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    CGRect scrollViewRect = CGRectMake(0, toolbarRect.size.height, viewRect.size.width, windowFrame.size.height - toolbarRect.size.height);
    attachmentsViewController = [[AttachmentsViewController alloc] initWithFrame:scrollViewRect];

    [self.view addSubview: attachmentsViewController.view];
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocumentViewBackground.png"]];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];
    [self.view addSubview:attachmentsViewController.view];
    infoViewController = [[DocumentInfoViewController alloc] init];
    infoViewController.view.frame = CGRectMake(0, 0, viewRect.size.width, windowFrame.size.height);
    [self createToolbar];
}

    // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        // Return YES for supported orientations
    return YES;
}

- (void)didReceiveMemoryWarning {
        // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
        // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [attachmentsViewController release];
    attachmentsViewController = nil;
    [infoViewController release];
    infoViewController = nil;
    [infoButton release];
    infoButton = nil;
    [penButton release];
    penButton = nil;
    [eraseButton release];
    eraseButton = nil;
    [commentButton release];
    commentButton = nil;
    [attachmentButton release];
    attachmentButton = nil;
    self.navigationBar = nil;
}

#pragma mark -
#pragma mark Managing the popover

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
        // Add the popover button to the toolbar.
    UIToolbar *toolbar = (UIToolbar *)self.navigationBar.topItem.leftBarButtonItem.customView;
    NSMutableArray *itemsArray = [toolbar.items mutableCopy];
    [itemsArray insertObject:barButtonItem atIndex:0];
    [toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
        // Remove the popover button from the toolbar.
    UIToolbar *toolbar = (UIToolbar *)self.navigationBar.topItem.leftBarButtonItem.customView;
    NSMutableArray *itemsArray = [toolbar.items mutableCopy];
    [itemsArray removeObject:barButtonItem];
    [toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}

- (void) showDocumentInfo:(id) sender
{
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:(infoButton.selected ?
									UIViewAnimationTransitionFlipFromRight:UIViewAnimationTransitionFlipFromLeft)
                           forView:attachmentsViewController.view cache:YES];
	
	if ([infoViewController.view superview])
    {
		[infoViewController.view removeFromSuperview];
        infoButton.selected = NO;
    }
	else
    {
        infoButton.selected = YES;
		[attachmentsViewController.view addSubview:infoViewController.view];
    }
    
	[UIView commitAnimations];
	
}

- (void)dealloc {
    self.document = nil;
    [attachmentsViewController release];
    [infoViewController release];
    [penButton release];
    [eraseButton release];
    [commentButton release];
    [attachmentButton release];
    self.navigationBar = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Actions
- (void) showAttachmentsList:(id) sender
{
    attachmentButton.selected = !attachmentButton.selected;
}
@end

@implementation DocumentViewController(Private)
- (void) createToolbar
{
    infoButton = [UIButton buttonWithType:UIButtonTypeCustom];

    
    infoButton = [self createButton:@"ButtonInfo.png" selectedState:@"ButtonInfoSelected.png" action:@selector(showDocumentInfo:)];
    [infoButton retain];

    penButton = [self createButton:@"ButtonPen.png" selectedState:@"ButtonPenSelected.png" action:nil];
    [penButton retain];

    eraseButton = [self createButton:@"ButtonErase.png" selectedState:@"ButtonEraseSelected.png" action:nil];
    [eraseButton retain];

    commentButton = [self createButton:@"ButtonComment.png" selectedState:@"ButtonCommentSelected.png" action:nil];
    [commentButton retain];

        //attachment button with label
#define kStdButtonWidth		106.0
#define kStdButtonHeight	40.0

    CGRect frame = CGRectMake(182.0, 5.0, kStdButtonWidth, kStdButtonHeight);
    attachmentButton = [[UIButton alloc] initWithFrame:frame];
        // or you can do this:
        //		UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	
	attachmentButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	attachmentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [attachmentButton setImage:[UIImage imageNamed:@"ButtonAttachment.png"] forState:UIControlStateNormal];
    [attachmentButton setImage:[UIImage imageNamed:@"ButtonAttachmentSelected.png"] forState:UIControlStateSelected];
    [attachmentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [attachmentButton setTitleColor:[UIColor colorWithRed:0.000 green:0.596 blue:0.992 alpha:1.0] forState:UIControlStateSelected];
    
	[attachmentButton addTarget:self action:@selector(showAttachmentsList:) forControlEvents:UIControlEventTouchUpInside];
    
        // in case the parent view draws with a custom color or gradient, use a transparent color
	attachmentButton.backgroundColor = [UIColor clearColor];    
    
    
	UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    UIBarButtonItem *attachmentBarButton = [[UIBarButtonItem alloc] initWithCustomView:attachmentButton];
    
    UIBarButtonItem *fleaxBarButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *penBarButton = [[UIBarButtonItem alloc] initWithCustomView:penButton];
    UIBarButtonItem *eraseBarButton = [[UIBarButtonItem alloc] initWithCustomView:eraseButton];
    UIBarButtonItem *commentBarButton = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    UIBarButtonItem *rotateCCVBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonRotateCCV.png"] style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *rotateCVBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonRotateCV.png"] style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *declineBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:nil];
    declineBarButton.style = UIBarButtonItemStyleBordered;
    UIBarButtonItem *acceptBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Accept", "Accept") style:UIBarButtonItemStyleBordered target:self action:nil];

    UIToolbar *leftToolbar = [[UIToolbar alloc]
                               initWithFrame:CGRectMake(0, 0, 100, 44)];
    UIToolbar *rightToolbar = [[UIToolbar alloc]
                               initWithFrame:CGRectMake(0, 0, 500, 44)];

    leftToolbar.items = [NSArray arrayWithObjects:infoBarButton, 
                          attachmentBarButton,
                          nil];
    rightToolbar.items = [NSArray arrayWithObjects: penBarButton, 
                                                    eraseBarButton, 
                                                    commentBarButton, 
                                                    rotateCCVBarButton, 
                                                    rotateCVBarButton,
                                                    fleaxBarButton1,
                                                    declineBarButton,
                                                    acceptBarButton,
                                                    nil];

    self.navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithCustomView:leftToolbar];

    self.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:rightToolbar];
    [leftToolbar release];
    [rightToolbar release];
    [infoBarButton release];
    [attachmentBarButton release];
    [fleaxBarButton1 release];
    [penBarButton release];
    [eraseBarButton release];
    [commentBarButton release];
    [rotateCCVBarButton release];
    [rotateCVBarButton release];
    [declineBarButton release];
    [acceptBarButton release];
}
- (UIButton *) createButton:(NSString *) aNormalImageName selectedState:(NSString *) aSelectedImageName action:(SEL) anAction;
{
    UIImage *normal = [UIImage imageNamed:aNormalImageName];
    UIImage *selected = [UIImage imageNamed:aSelectedImageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, normal.size.width, normal.size.height );    
    [button setImage:normal forState:UIControlStateNormal];
    [button setImage:selected forState:UIControlStateSelected];
	[button addTarget:self action:anAction forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}
@end
