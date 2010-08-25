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

@interface DocumentViewController(Private)
- (void) createToolbar;
- (UIButton *) createButton:(NSString *) aNormalImageName selectedState:(NSString *) aSelectedImageName action:(SEL) anAction;
@end
@implementation DocumentViewController

#pragma mark -
#pragma mark Properties
@synthesize toolbar, document;


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
    if ([attachments count]) 
    {
        Attachment *firstAttachment = [attachments objectAtIndex:0];
        attachmentsViewController.attachment = firstAttachment;
    }

        //infoViewController removed
    infoButton.selected = NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect viewRect = self.view.bounds;
    CGRect toolbarRect = self.toolbar.bounds;
    
    CGRect scrollViewRect = CGRectMake(0, viewRect.origin.y + toolbarRect.size.height, viewRect.size.width, viewRect.size.height - toolbarRect.size.height);
    attachmentsViewController = [[AttachmentsViewController alloc] initWithFrame:scrollViewRect];

    [self.view addSubview: attachmentsViewController.view];
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocumentViewBackground.png"]];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];
    [self.view addSubview:attachmentsViewController.view];
    infoViewController = [[DocumentInfoViewController alloc] init];
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
    self.toolbar = nil;
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
}

#pragma mark -
#pragma mark Managing the popover

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
        // Add the popover button to the toolbar.
    NSMutableArray *itemsArray = [toolbar.items mutableCopy];
    [itemsArray insertObject:barButtonItem atIndex:0];
    [toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
        // Remove the popover button from the toolbar.
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
	
	[UIView setAnimationTransition:([attachmentsViewController.view superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
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
    self.toolbar = nil;
    self.document = nil;
    [attachmentsViewController release];
    [infoViewController release];
    [penButton release];
    [eraseButton release];
    [commentButton release];
    [super dealloc];
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
    
    
	UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    UIBarButtonItem *fleaxBarButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *penBarButton = [[UIBarButtonItem alloc] initWithCustomView:penButton];
    UIBarButtonItem *eraseBarButton = [[UIBarButtonItem alloc] initWithCustomView:eraseButton];
    UIBarButtonItem *commentBarButton = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    UIBarButtonItem *rotateCCVBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonRotateCCV.png"] style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *rotateCVBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonRotateCV.png"] style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *fleaxBarButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *declineBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:nil];
    declineBarButton.style = UIBarButtonItemStyleBordered;
    UIBarButtonItem *acceptBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Accept", "Accept") style:UIBarButtonItemStyleBordered target:self action:nil];
	self.toolbar.items = [NSArray arrayWithObjects:infoBarButton, 
                                                    fleaxBarButton1,
                                                    penBarButton, 
                                                    eraseBarButton, 
                                                    commentBarButton, 
                                                    rotateCCVBarButton, 
                                                    rotateCVBarButton,
                                                    fleaxBarButton2,
                                                    declineBarButton,
                                                    acceptBarButton,
                                                    nil];
    
    [infoBarButton release];
    [fleaxBarButton1 release];
    [penBarButton release];
    [eraseBarButton release];
    [commentBarButton release];
    [rotateCCVBarButton release];
    [rotateCVBarButton release];
    [fleaxBarButton2 release];
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
