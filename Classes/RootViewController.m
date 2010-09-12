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
#import "DocumentInfoViewController.h"
#import "ClipperViewController.h"
#import "PaintingToolsViewController.h"
#import "DocumentsListViewController.h"
#import "Folder.h"

static NSString* ClipperOpenedContext = @"ClipperOpenedContext";
static NSString* AttachmentContext    = @"AttachmentContext";
@interface RootViewController(Private)
- (void) createToolbar;
- (void) moveToArchive;
-(void) setCanEdit:(BOOL) value;
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
    
    [document release];
    document = [aDocument retain];
    
    if (![document.isRead boolValue])
        document.isRead = [NSNumber numberWithBool:YES];
    [[DataSource sharedDataSource] commit];
    
   documentInfoViewController.document = self.document;
   [self setCanEdit: [self.document.isEditable boolValue]];
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
    self.view.frame = CGRectMake(0, 20, windowFrame.size.width, windowFrame.size.height-20);
    self.view.backgroundColor = [UIColor blackColor];
    
    [self createToolbar];
    
    //background image
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RootBackground.png"]];
    CGRect toolbarFrame = toolbar.bounds;
    CGFloat backgroundImageHeight = windowFrame.size.height-toolbarFrame.size.height;
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
    contentView.userInteractionEnabled = YES;
    contentViewSize.width-=5;

    //attachments view
    CGRect attachmentsViewFrame = CGRectMake(0, 5, contentViewSize.width, contentViewSize.height);
    attachmentsViewController = [[AttachmentsViewController alloc] init];
    attachmentsViewController.view.frame = attachmentsViewFrame;
    
    //attachmentPicker view
    documentInfoViewController = [[DocumentInfoViewController alloc] init];
    CGRect documentInfoViewControllerFrame = CGRectMake(0, 5, contentViewSize.width, 300);
    documentInfoViewController.view.frame = documentInfoViewControllerFrame;
    [documentInfoViewController addObserver:self
                            forKeyPath:@"attachment"
                               options:0
                               context:&AttachmentContext];

    paintingToolsViewController = [[PaintingToolsViewController alloc] init];
    CGSize paintingSize = paintingToolsViewController.view.frame.size;
    CGFloat paintingToolsOffsetFromLeftEdge = paintingSize.width - contentView.frame.origin.x;
    paintingToolsOffsetFromLeftEdge = paintingToolsOffsetFromLeftEdge<0?0:paintingToolsOffsetFromLeftEdge;
    CGRect paintingToolsFrame = CGRectMake(contentView.frame.origin.x-paintingSize.width+paintingToolsOffsetFromLeftEdge, contentHeightOffset+33, paintingSize.width, paintingSize.height);
    paintingToolsViewController.view.frame = paintingToolsFrame;
    
    [contentView addSubview: documentInfoViewController.view];
    [contentView addSubview: attachmentsViewController.view];

    [self.view addSubview:paintingToolsViewController.view];
    [self.view addSubview:contentView];
    [self.view addSubview:clipperViewController.view];
    [self.view bringSubviewToFront:toolbar];

    documentInfoViewController.document = self.document;
    [self setCanEdit: [self.document.isEditable boolValue]];
}

    // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [attachmentsViewController release];
    attachmentsViewController = nil;
    [clipperViewController removeObserver:self forKeyPath:@"opened"];
    [clipperViewController release];
    clipperViewController = nil;
    [documentInfoViewController removeObserver:self forKeyPath:@"attachment"];
    [documentInfoViewController release];
    documentInfoViewController = nil;
    [contentView release];
    contentView = nil;
    [toolbar release];
    toolbar = nil;
    [declineButton release];
    declineButton = nil;
    [acceptButton release];
    acceptButton = nil;
}

- (void) dealloc
{
    [attachmentsViewController release];
    attachmentsViewController = nil;
    [clipperViewController removeObserver:self forKeyPath:@"opened"];
    [clipperViewController release];
    clipperViewController = nil;
    [documentInfoViewController removeObserver:self forKeyPath:@"attachment"];
    [documentInfoViewController release];
    documentInfoViewController = nil;
    [contentView release];
    contentView = nil;
    [toolbar release];
    toolbar = nil;
    self.document = nil;
    self.folder = nil;
    [declineButton release];
    declineButton = nil;
    [acceptButton release];
    acceptButton = nil;
    
	[super dealloc];
}
#pragma mark -
#pragma mark Actions
-(void) showDocuments:(id) sender
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *foldersData = [currentDefaults objectForKey:@"folders"];
    
    NSAssert(foldersData != nil, @"No folders found");
    
    NSArray *folders = [NSKeyedUnarchiver unarchiveObjectWithData:foldersData];
    Folder *f = [folders objectAtIndex:((UIButton *)sender).tag];

    // Create the modal view controller
    DocumentsListViewController *viewController = [[DocumentsListViewController alloc] init];
    
    viewController.document = self.document;

    viewController.folder = f;
    
    viewController.delegate = self;
    
    // We are the delegate responsible for dismissing the modal view 
    //    viewController.delegate = self;
    
    // Create a Navigation controller
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:viewController];
    
    //paint navbar background - works only here!
    UINavigationBar *bar = navController.navigationBar;
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage: [UIImage imageNamed:@"DocumentsListNavigationbarBackground.png"]];
    bar.backgroundColor = backgroundColor;
    [backgroundColor release];
    
    navController.toolbar.barStyle = UIBarStyleBlack;
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // show the navigation controller modally
    [self presentModalViewController:navController animated:YES];
    
    // Clean up resources
    [navController release];
    [viewController release];  
}

- (void) declineDocument:(id) sender
{
    [self moveToArchive];
}

- (void) acceptDocument:(id) sender
{
    [self moveToArchive];
}

#pragma mark - 
#pragma mark DocumentsListDelegate
-(void) documentDidChanged:(DocumentsListViewController *) sender
{
    self.document = sender.document;
    [sender dismiss:nil];
}
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

        CGSize documentInfoViewControllerSize = documentInfoViewController.view.frame.size;
        
        CGRect attachmentsViewOldFrame = attachmentsViewController.view.frame;
        CGRect attachmentsViewFrame = CGRectMake(attachmentsViewOldFrame.origin.x,attachmentsViewOldFrame.origin.y+(clipperViewController.opened?1:-1)*documentInfoViewControllerSize.height, attachmentsViewOldFrame.size.width, attachmentsViewOldFrame.size.height);
        attachmentsViewController.view.frame = attachmentsViewFrame;
        [UIView commitAnimations];
    }
    else if (context == &AttachmentContext)
    {
        if (clipperViewController.opened)
            clipperViewController.opened = NO;
        attachmentsViewController.attachment = documentInfoViewController.attachment;
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
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *foldersData = [currentDefaults objectForKey:@"folders"];
    
    NSAssert(foldersData != nil, @"No folders found");
    
    NSArray *folders = [NSKeyedUnarchiver unarchiveObjectWithData:foldersData];

    NSUInteger foldersCount = [folders count];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:foldersCount+3];

    for (NSUInteger i = 0; i < foldersCount; i++)
    {
        Folder *f = [folders objectAtIndex:i];
        UIButton *button = [UIButton imageButtonWithTitle:[@" " stringByAppendingString: f.localizedName]
                                                            target:self
                                                          selector:@selector(showDocuments:)
                                                             image:f.icon
                                                     imageSelected:f.icon];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 14];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView: button];
        button.tag = i;
        [items addObject: barButton];
        [barButton release];
    }
    
    UIBarButtonItem *flexBarButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject: flexBarButton1];
    [flexBarButton1 release];

    declineButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Decline", "Decline") style: UIBarButtonItemStyleBordered target:self action: @selector(declineDocument:)];
    [items addObject: declineButton];

    acceptButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Accept", "Accept") style: UIBarButtonItemStyleBordered target:self action:@selector(acceptDocument:)];
    
    [items addObject: acceptButton];

    toolbar = [[UIToolbar alloc]
                               initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];

    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    toolbar.backgroundColor = [UIColor clearColor];
    
    toolbar.items = items;
    [self.view addSubview: toolbar];
}
- (void) moveToArchive
{
    [self setCanEdit:NO];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.75f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(archivingAnimationDidStopped:finished:context:)];
    
    contentView.transform = CGAffineTransformScale (
                                                    CGAffineTransformMakeTranslation(-200.0, -475.0),
                                                    0.1,
                                                    0.1
                                                    );
    //http://ameyashetti.wordpress.com/2009/08/17/view-animation-tutorial/
    //    attachmentsViewController.view.transform = CGAffineTransformConcat(
    //                                                                       
    //                                                                       CGAffineTransformConcat(
    //                                                                                               
    //                                                                                               CGAffineTransformConcat(
    //                                                                                                                        CGAffineTransformMakeTranslation(-12,0),CGAffineTransformMakeScale(3,3)),
    //                                                                                               
    //                                                                                               CGAffineTransformMakeRotation(3.14)),
    //                                                                       
    //                                                                       CGAffineTransformMake(1,2,3,4,5,6));
    //CGAffineTransformConcat(CGAffineTransformMakeScale(0,0), CGAffineTransformMakeTranslation(-1000.0, -1000.0))
    
    //    attachmentsViewController.view.frame = CGRectZero;
    
    [UIView commitAnimations];    
}
- (void)archivingAnimationDidStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    contentView.hidden = YES;
    contentView.transform = CGAffineTransformIdentity;
    contentView.hidden = NO;
    [UIView setAnimationDelegate:nil];
    [UIView setAnimationDidStopSelector:nil];
    [[DataSource sharedDataSource] archiveDocument:self.document];
    self.document = nil;
}
-(void) setCanEdit:(BOOL) value
{
    if (canEdit == value)
        return;
    canEdit = value;
    if (canEdit)
    {
        [acceptButton setTitle:NSLocalizedString(@"Accept", "Accept")];
        [acceptButton setStyle:UIBarButtonItemStyleBordered];
        [acceptButton setEnabled:YES];
        
        [declineButton setTitle:NSLocalizedString(@"Decline", "Decline")];
        [declineButton setStyle:UIBarButtonItemStyleBordered];
        [declineButton setEnabled:YES];
        
        paintingToolsViewController.view.hidden = NO;
        paintingToolsViewController.view.userInteractionEnabled = YES;
    }
    else
    {
        [acceptButton setStyle:UIBarButtonItemStylePlain];
        [acceptButton setEnabled:NO];
        [acceptButton setTitle:@""];
        
        [declineButton setStyle:UIBarButtonItemStylePlain];
        [declineButton setEnabled:NO];
        [declineButton setTitle:@""];

        paintingToolsViewController.view.hidden = YES;
        paintingToolsViewController.view.userInteractionEnabled = NO;
    }
}
@end
