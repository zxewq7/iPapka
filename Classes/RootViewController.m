    //
    //  DocumentViewController.m
    //  Meester
    //
    //  Created by Vladimir Solomenchuk on 10.08.10.
    //  Copyright 2010 __MyCompanyName__. All rights reserved.
    //

#import "RootViewController.h"
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
#import "UIToolbarWithCustomBackground.h"

#define kAttachmentLabelTag 1

@interface RootViewController(Private)
- (void) createToolbar;
@end

@implementation RootViewController

#pragma mark -
#pragma mark Properties
@synthesize document;


-(void) setDocument:(DocumentManaged *) aDocument
{
    if (document == aDocument)
        return;
    [document saveDocument];
    
    [document release];
    document = [aDocument retain];
    
//    if (![document.isRead boolValue])
//        document.isRead = [NSNumber numberWithBool:YES];
//    [[DataSource sharedDataSource] commit];
//
//    infoViewController.document = document;
//    
//    NSArray *attachments = document.document.attachments;
//    NSUInteger numberOfAttachments = [attachments count];
//    if (numberOfAttachments) 
//    {
//        Attachment *firstAttachment = [attachments objectAtIndex:0];
//        attachmentsViewController.attachment = firstAttachment;
//        NSString *attachmentTitle = [NSString stringWithFormat:@"%d %@ %d", 1, NSLocalizedString(@"of", "of"), numberOfAttachments];
//        [attachmentButton setTitle:attachmentTitle forState:UIControlStateNormal];
//        attachmentButton.enabled = YES;
//    }
//    else
//        attachmentButton.enabled = NO;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([attachmentsViewController respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]) 
        [attachmentsViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)loadView
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,1024)];
    
    self.view = v;
    
    [v release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    self.view.frame = CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height);
    self.view.backgroundColor = [UIColor redColor];
    
    [self createToolbar];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RootBackground.png"]];
    
    CGRect toolbarFrame = toolbar.bounds;
    backgroundView.frame = CGRectMake(0, toolbarFrame.origin.y+toolbarFrame.size.height, windowFrame.size.width, windowFrame.size.height-toolbarFrame.size.height);
    //[self.view addSubview:backgroundView];
    [backgroundView release];
    self.navigationItem;

//    CGRect scrollViewRect = CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height);
//    attachmentsViewController = [[AttachmentsViewController alloc] initWithFrame:scrollViewRect];
    [self.view addSubview:attachmentsViewController.view];

    
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
    [toolbar release];
    toolbar = nil;
}
#pragma mark -
#pragma mark Actions

@end

@implementation RootViewController(Private)
- (void) createToolbar
{
    [toolbar release];
    
    UIButton *documentsButton = [UIButton imageButtonWithTitle:[@" " stringByAppendingString: NSLocalizedString(@"Documents", "Documents")]
                                               target:self
                                             selector:nil
                                                image:[UIImage imageNamed:@"ButtonDocuments.png"]
                                        imageSelected:[UIImage imageNamed:@"ButtonDocuments.png"]];
    [documentsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	UIBarButtonItem *documentsBarButton = [[UIBarButtonItem alloc] initWithCustomView: documentsButton];

    UIButton *archiveButton = [UIButton imageButtonWithTitle:[@" " stringByAppendingString: NSLocalizedString(@"Archive", "Archive")]
                                                        target:self
                                                      selector:nil
                                                         image:[UIImage imageNamed:@"ButtonArchive.png"]
                                                 imageSelected:[UIImage imageNamed:@"ButtonArchive.png"]];
    [archiveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	UIBarButtonItem *archiveBarButton = [[UIBarButtonItem alloc] initWithCustomView: archiveButton];

    UIBarButtonItem *fleaxBarButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *declineButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Decline", "Decline") style: UIBarButtonItemStyleBordered target:self action:nil];
    UIBarButtonItem *acceptButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Accept", "Accept") style: UIBarButtonItemStyleBordered target:self action:nil];

    toolbar = [[UIToolbarWithCustomBackground alloc]
                               initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];

    toolbar.barStyle = UIBarStyleBlack;
    
    toolbar.tintColor = [UIColor blackColor];
    
    toolbar.backgroundColor = [UIColor blackColor];
    
    toolbar.items = [NSArray arrayWithObjects:  documentsBarButton, 
                                                archiveBarButton,
                                                fleaxBarButton1,
                                                declineButton,
                                                acceptButton,
                                                    nil];
    [documentsButton release];
    [archiveBarButton release];
    [fleaxBarButton1 release];
    [declineButton release];
    [acceptButton release];
    [self.view addSubview: toolbar];
}
@end
