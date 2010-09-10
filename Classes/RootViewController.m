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
#import "AttachmentsViewController.h"
#import "UIButton+Additions.h"
#import "AttachmentPickerController.h"
#import "UIToolbarWithCustomBackground.h"
#import "ClipperViewController.h"

static NSString* ClipperOpenedContext = @"ClipperOpenedContext";

@interface RootViewController(Private)
- (void) createToolbar;
@end

@implementation RootViewController

#pragma mark -
#pragma mark Properties
@synthesize document, folder;

-(void) setFolder:(Folder *) aFolder
{
    if (folder == aFolder)
        return;
    [folder release];
    folder = [aFolder retain];
    
    NSArray *documents = [[DataSource sharedDataSource] documentsForFolder:aFolder];
    if ([documents count])
        self.document = [documents objectAtIndex:0];
}

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
    
    NSArray *attachments = document.document.attachments;
    NSUInteger numberOfAttachments = [attachments count];
    if (numberOfAttachments) 
    {
        Attachment *firstAttachment = [attachments objectAtIndex:0];
        attachmentsViewController.attachment = firstAttachment;
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([attachmentsViewController respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]) 
        [attachmentsViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)loadView
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.view = v;
    
    [v release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    self.view.frame = CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height);
    self.view.backgroundColor = [UIColor blackColor];
    
    [self createToolbar];
    
    //background image
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RootBackground.png"]];
    CGRect toolbarFrame = toolbar.bounds;
    CGFloat backgroundImageHeight = windowFrame.size.height-toolbarFrame.size.height-20;
    backgroundView.frame = CGRectMake(0, toolbarFrame.origin.y+toolbarFrame.size.height, windowFrame.size.width, backgroundImageHeight);
    [self.view addSubview:backgroundView];
    [backgroundView release];
    
    CGRect viewBounds = self.view.bounds;

    //clipper
    clipperViewController = [[ClipperViewController alloc] init];
    CGSize clipperSize = clipperViewController.view.frame.size;
    CGRect clipperFrame = CGRectMake((viewBounds.size.width-clipperSize.width)/2, 0,clipperSize.width, clipperSize.height);
    clipperViewController.view.frame = clipperFrame;
    [clipperViewController addObserver:self
                                 forKeyPath:@"opened"
                                    options:0
                                    context:&ClipperOpenedContext];
    
    contentHeightOffset = toolbarFrame.origin.y+toolbarFrame.size.height+[clipperViewController contentOffset];

    //contentView
    contentView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PaperBack.png"]];
    
    CGSize contentViewSize = contentView.frame.size;
    
    contentView.frame = CGRectMake((viewBounds.size.width-contentViewSize.width)/2, contentHeightOffset, contentViewSize.width, contentViewSize.height);
    contentView.backgroundColor = [UIColor redColor];
    contentViewSize.width-=5;

    //attachments view
    CGRect attachmentsViewFrame = CGRectMake(0, 5, contentViewSize.width, contentViewSize.height);
    attachmentsViewController = [[AttachmentsViewController alloc] init];
    attachmentsViewController.view.frame = attachmentsViewFrame;
    
    //attachmentPicker view
    attachmentPickerController = [[AttachmentPickerController alloc] init];
    CGRect attachmentPickerFrame = CGRectMake(0, 5, contentViewSize.width, 300);
    attachmentPickerController.view.frame = attachmentPickerFrame;
    
    [contentView addSubview: attachmentPickerController.view];
    [contentView addSubview: attachmentsViewController.view];

    [self.view addSubview:contentView];
    [self.view addSubview:clipperViewController.view];
    
    if (self.document)
    {
        NSArray *attachments = document.document.attachments;
        NSUInteger numberOfAttachments = [attachments count];
        if (numberOfAttachments) 
        {
            Attachment *firstAttachment = [attachments objectAtIndex:0];
            attachmentsViewController.attachment = firstAttachment;
            attachmentPickerController.document = self.document.document;
            attachmentPickerController.attachment = firstAttachment;
        }
    }

}

    // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [attachmentsViewController release];
    attachmentsViewController = nil;
    [clipperViewController release];
    clipperViewController = nil;
    [attachmentPickerController removeObserver:self forKeyPath:@"opened"];
    [attachmentPickerController release];
    attachmentPickerController = nil;
    [contentView release];
    contentView = nil;
    [toolbar release];
    toolbar = nil;
}

- (void) dealloc
{
    [attachmentsViewController release];
    attachmentsViewController = nil;
    [clipperViewController release];
    clipperViewController = nil;
    [attachmentPickerController removeObserver:self forKeyPath:@"opened"];
    [attachmentPickerController release];
    attachmentPickerController = nil;
    [contentView release];
    contentView = nil;
    [toolbar release];
    toolbar = nil;
    self.document = nil;
    self.folder = nil;
	[super dealloc];
}
#pragma mark -
#pragma mark Actions

#pragma mark -
#pragma mark Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &ClipperOpenedContext)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.75];

        CGSize attachmentPickerSize = attachmentPickerController.view.frame.size;
        
        CGRect attachmentsViewOldFrame = attachmentsViewController.view.frame;
        CGRect attachmentsViewFrame = CGRectMake(attachmentsViewOldFrame.origin.x,attachmentsViewOldFrame.origin.y+(clipperViewController.opened?1:-1)*attachmentPickerSize.height, attachmentsViewOldFrame.size.width, attachmentsViewOldFrame.size.height);
        attachmentsViewController.view.frame = attachmentsViewFrame;
        [UIView commitAnimations];
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
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
