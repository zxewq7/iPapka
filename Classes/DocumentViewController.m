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
#import "UIButton+Additions.h"
#import "AttachmentPickerController.h"
#import "AttachmentPageViewController.h"

#define kAttachmentLabelTag 1

@interface DocumentViewController(Private)
- (void) createToolbar;
@end
@implementation DocumentViewController

#pragma mark -
#pragma mark Properties
@synthesize navigationController, document;


-(void) setDocument:(DocumentManaged *) aDocument
{
    if (document == aDocument)
        return;
    [document saveDocument];
    
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

- (void)loadView
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,180)];
    
    self.view = v;
    
    [v release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    self.view.frame = CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height);
    CGRect scrollViewRect = CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height);
    attachmentsViewController = [[AttachmentsViewController alloc] initWithFrame:scrollViewRect];

    [self.view addSubview: attachmentsViewController.view];
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocumentViewBackground.png"]];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];
    [self.view addSubview:attachmentsViewController.view];
    infoViewController = [[DocumentInfoViewController alloc] init];
    infoViewController.view.frame = CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height);
    if (!(leftToolbar && rightToolbar))
        [self createToolbar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithCustomView:leftToolbar];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithCustomView:rightToolbar];
    
}

    // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        // Return YES for supported orientations
    return YES;
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
    self.navigationController = nil;
    [leftToolbar release];
    leftToolbar = nil;
    [rightToolbar release];
    rightToolbar = nil;
    [attachmentPickerController release];
    attachmentPickerController = nil;
    [popoverController release];
    popoverController = nil;
}

#pragma mark -
#pragma mark Managing the popover

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
    if (!(leftToolbar && rightToolbar)) // for some reason this method called before any object initialization
        [self createToolbar];

        // Add the popover button to the toolbar.
    NSMutableArray *itemsArray = [leftToolbar.items mutableCopy];
    [itemsArray insertObject:barButtonItem atIndex:0];
    [leftToolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
        // Remove the popover button from the toolbar.
    NSMutableArray *itemsArray = [leftToolbar.items mutableCopy];
    [itemsArray removeObject:barButtonItem];
    [leftToolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}

- (void)dealloc {
    self.document = nil;
    [attachmentsViewController release];
    [infoViewController release];
    [penButton release];
    [eraseButton release];
    [commentButton release];
    [attachmentButton release];
    self.navigationController = nil;
    [leftToolbar release];
    [rightToolbar release];
    [attachmentPickerController release];
    [popoverController release];
    [super dealloc];
}
#pragma mark -
#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)pc
{
    if (pc == popoverController) 
        attachmentButton.selected = NO;
}

#pragma mark -
#pragma mark Actions
- (void) showAttachmentsList:(id) sender
{
    if (!attachmentPickerController)
    {
        attachmentPickerController = [[AttachmentPickerController alloc] init];
        attachmentPickerController.target = self;
        attachmentPickerController.selector = @selector(setAttachment:);
    }
    
    if (!popoverController)
    {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:attachmentPickerController];
        popoverController.delegate = self;
    }
    
    attachmentPickerController.document = document.document;

    UIView *button = (UIView *)sender;
	[popoverController presentPopoverFromRect:button.bounds inView:[button superview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    attachmentButton.selected = YES;
}

-(void) setAttachment:(id) sender
{
    [popoverController dismissPopoverAnimated:YES];
    attachmentButton.selected = NO;
    attachmentsViewController.attachment = attachmentPickerController.attachment;
}

- (void) enableMarker:(id) sender
{
    BOOL isPainting = !penButton.selected;
    commentButton.selected = NO;
    penButton.selected = isPainting;
    eraseButton.selected = NO;
    attachmentsViewController.commenting = penButton.selected || eraseButton.selected || commentButton.selected;
    [attachmentsViewController.currentPage enableMarker:isPainting];
    if (!isPainting) 
        [document saveDocument];
}

- (void) enableEraser:(id) sender
{
    BOOL isPainting = !eraseButton.selected;
    commentButton.selected = NO;
    penButton.selected = NO;
    eraseButton.selected = isPainting;
    attachmentsViewController.commenting = penButton.selected || eraseButton.selected || commentButton.selected;
    [attachmentsViewController.currentPage enableEraser:isPainting];
    if (!isPainting) 
        [document saveDocument];
}

- (void) enableComment:(id) sender
{
    BOOL isPainting = !commentButton.selected;
    commentButton.selected = isPainting;
    penButton.selected = NO;
    eraseButton.selected = NO;
    attachmentsViewController.commenting = penButton.selected || eraseButton.selected || commentButton.selected;
    [attachmentsViewController.currentPage enableStamper:isPainting];
    if (!isPainting) 
        [document saveDocument];
}


- (void) rotateCCV:(id) sender
{
    [attachmentsViewController rotate: -90];
    [document saveDocument];
}

- (void) rotateCV:(id) sender
{
    [attachmentsViewController rotate: 90];
    [document saveDocument];
}

- (void) showDocumentInfo:(id) sender
{
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
        infoViewController.navigationController = self.navigationController;
		[attachmentsViewController.view addSubview:infoViewController.view];
    }
    
	[UIView commitAnimations];
	
}
@end

@implementation DocumentViewController(Private)
- (void) createToolbar
{
    infoButton = [UIButton imageButton:self
                              selector:@selector(showDocumentInfo:)
                                 imageName:@"ButtonInfo.png"
                         imageNameSelected:@"ButtonInfoSelected.png"];
    [infoButton retain];

    penButton = [UIButton imageButton:self
                             selector:@selector(enableMarker:)
                            imageName:@"ButtonPen.png"
                    imageNameSelected:@"ButtonPenSelected.png"];
    [penButton retain];

    eraseButton = [UIButton imageButton:self
                               selector:@selector(enableEraser:)
                              imageName:@"ButtonErase.png"
                      imageNameSelected:@"ButtonEraseSelected.png"];
    [eraseButton retain];

    commentButton = [UIButton imageButton:self
                                 selector:@selector(enableComment:)
                                imageName:@"ButtonComment.png"
                        imageNameSelected:@"ButtonCommentSelected.png"];
    [commentButton retain];

    attachmentButton = [UIButton imageButtonWithTitle:@""
                                               target:self
                                             selector:@selector(showAttachmentsList:)
                                            imageName:@"ButtonAttachment.png"
                                    imageNameSelected:@"ButtonAttachmentSelected.png"];
	attachmentButton.backgroundColor = [UIColor clearColor];    
    
    
	UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    UIBarButtonItem *attachmentBarButton = [[UIBarButtonItem alloc] initWithCustomView:attachmentButton];
    
    UIBarButtonItem *fleaxBarButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *penBarButton = [[UIBarButtonItem alloc] initWithCustomView:penButton];
    UIBarButtonItem *eraseBarButton = [[UIBarButtonItem alloc] initWithCustomView:eraseButton];
    UIBarButtonItem *commentBarButton = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    UIBarButtonItem *rotateCCVBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonRotateCCV.png"] style:UIBarButtonItemStylePlain target:self action:@selector(rotateCCV:)];
    UIBarButtonItem *rotateCVBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonRotateCV.png"] style:UIBarButtonItemStylePlain target:self action:@selector(rotateCV:)];
    UIBarButtonItem *declineBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:nil];
    declineBarButton.style = UIBarButtonItemStyleBordered;
    UIBarButtonItem *acceptBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Accept", "Accept") style:UIBarButtonItemStyleBordered target:self action:nil];

    leftToolbar = [[UIToolbar alloc]
                               initWithFrame:CGRectMake(0, 0, 300, 44)];
    rightToolbar = [[UIToolbar alloc]
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
    self.navigationItem.title = @"";
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
@end
