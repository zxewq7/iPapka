    //
    //  DocumentViewController.m
    //  iPapka
    //
    //  Created by Vladimir Solomenchuk on 10.08.10.
    //  Copyright 2010 __MyCompanyName__. All rights reserved.
    //

#import "RootViewController.h"
#import "Document.h"
#import "DataSource.h"
#import "AttachmentsViewController.h"
#import "UIButton+Additions.h"
#import "DocumentInfoViewController.h"
#import "ClipperViewController.h"
#import "PaintingToolsViewController.h"
#import "DocumentsListViewController.h"
#import "Folder.h"
#import "ResolutionViewController.h"
#import "RotateableImageView.h"
#import "PageControl.h"
#import "DocumentResolution.h"
#import "SignatureCommentViewController.h"
#import "DataSource.h"
#import "MBProgressHUD.h"

static NSString* ArchiveAnimationId = @"ArchiveAnimationId";
static NSString* OpenClipperAnimationId = @"OpenClipperAnimationId";

static NSString* ClipperOpenedContext = @"ClipperOpenedContext";
static NSString* AttachmentContext    = @"AttachmentContext";
static NSString* LinkContext          = @"LinkContext";
static NSString* SyncingContext       = @"SyncingContext";

#define kLeftMargin 7.0f
#define kRightMargin 10.0f

#define kTopMargin 7.0f

@interface RootViewController(Private)
- (void) createToolbar;
- (void) moveToArchive;
- (void) setCanEdit:(BOOL) value;
- (void) updateContent;
- (void) showResolution:(id) sender;
- (void) showSignatureComment:(id) sender;
- (void) findAndSetDocumentInFolder;
@end

@implementation RootViewController

#pragma mark -
#pragma mark Properties
@synthesize document;

-(void) setDocument:(Document *) aDocument
{
    if (document == aDocument)
        return;
    
    [document release];
    document = [aDocument retain];
    
    if (!document.isReadValue)
    {
        document.isReadValue = YES;
        [[DataSource sharedDataSource] commit];
    }
    
    [self updateContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    CGRect viewFrame = self.view.frame;
    
    [self createToolbar];
    
    //background image
    
    CGRect toolbarFrame = toolbar.bounds;

    RotateableImageView *backgroundView = [[[RotateableImageView alloc] initWithImage:[UIImage imageNamed:@"RootBackground.png"]] autorelease];
    backgroundView.portraitImage = [UIImage imageNamed: @"RootBackground.png"];
    backgroundView.landscapeImage = [UIImage imageNamed: @"RootBackground-Landscape.png"];
    backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight);

    CGRect backgroundViewFrame = backgroundView.frame;
    backgroundViewFrame.origin.x = 0;
    backgroundViewFrame.origin.y = toolbarFrame.origin.y+toolbarFrame.size.height;
    backgroundView.frame = backgroundViewFrame;
    backgroundView.userInteractionEnabled = YES;
    [self.view addSubview:backgroundView];
    
    CGSize viewSize = self.view.bounds.size;

    //clipper
    clipperViewController = [[ClipperViewController alloc] init];
    CGRect clipperFrame = clipperViewController.view.frame;
    clipperFrame.origin.x = round((viewSize.width - clipperFrame.size.width) / 2);
    clipperFrame.origin.y = 0;
    clipperViewController.view.frame = clipperFrame;
    clipperViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    [clipperViewController addObserver:self
                                 forKeyPath:@"opened"
                                    options:0
                                    context:&ClipperOpenedContext];
    
    [self.view addSubview:clipperViewController.view];
    
    [clipperViewController counfigureTapzones];
    
    contentHeightOffset = toolbarFrame.origin.y+toolbarFrame.size.height+[clipperViewController contentOffset];

    //paper view
    RotateableImageView *paperView = [[[RotateableImageView alloc] initWithImage:[UIImage imageNamed:@"Papers.png"]] autorelease];
    paperView.portraitImage = [UIImage imageNamed: @"Papers.png"];
    paperView.landscapeImage = [UIImage imageNamed: @"Papers-Landscape.png"];

    CGRect paperViewFrame = paperView.frame;
    paperViewFrame.origin.x = round((viewSize.width - paperViewFrame.size.width) / 2);
    paperViewFrame.origin.y = 43;
    paperView.frame = paperViewFrame;
    
    paperView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);

    [backgroundView addSubview:paperView];
    
    //fix paintingtools frame
    
    paintingToolsViewController = [[PaintingToolsViewController alloc] init];
    
    CGRect paintingToolsFrame = paintingToolsViewController.view.frame;
    paintingToolsFrame.origin.x = 4.0f;
    paintingToolsFrame.origin.y = 60.0f;
    paintingToolsViewController.view.frame = paintingToolsFrame;
    
    paintingToolsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    [backgroundView addSubview:paintingToolsViewController.view];

    
    //resolution button
    resolutionButton = [UIButton buttonWithBackgroundAndTitle:NSLocalizedString(@"Resolution", "Resolution")
                                                    titleFont:[UIFont boldSystemFontOfSize:12]
                                                       target:self
                                                     selector:@selector(showResolution:)
                                                        frame:CGRectMake(0, 0, 20, 30)
                                                addLabelWidth:YES
                                                        image:[UIImage imageNamed:@"ButtonSquare.png"]
                                                 imagePressed:[UIImage imageNamed:@"ButtonSquareSelected.png"]
                                                 leftCapWidth:10.0f
                                                darkTextColor:NO];
    
    [resolutionButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5] forState:UIControlStateNormal];
    resolutionButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    CGRect resolutionButtonFrame = resolutionButton.frame;
    resolutionButtonFrame.origin.x = 47;
    resolutionButtonFrame.origin.y = 12.0f;
    resolutionButton.frame = resolutionButtonFrame;
    
    resolutionButton.frame = resolutionButtonFrame;
    
    resolutionButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    [resolutionButton retain];
    
    [backgroundView addSubview:resolutionButton];
    
    //signatureCommentButton
    signatureCommentButton = [UIButton buttonWithBackgroundAndTitle:NSLocalizedString(@"Comment", "Comment")
                                                          titleFont:[UIFont boldSystemFontOfSize:12]
                                                             target:self
                                                           selector:@selector(showSignatureComment:)
                                                              frame:CGRectMake(0, 0, 20, 30)
                                                      addLabelWidth:YES
                                                              image:[UIImage imageNamed:@"ButtonSquare.png"]
                                                       imagePressed:[UIImage imageNamed:@"ButtonSquareSelected.png"]
                                                       leftCapWidth:10.0f
                                                      darkTextColor:NO];
    
    [signatureCommentButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5] forState:UIControlStateNormal];
    signatureCommentButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    CGRect signatureCommentButtonFrame = signatureCommentButton.frame;
    
    signatureCommentButtonFrame.origin.x = resolutionButtonFrame.origin.x;
    signatureCommentButtonFrame.origin.y = resolutionButtonFrame.origin.y;
    
    signatureCommentButton.frame = signatureCommentButtonFrame;
    signatureCommentButton.autoresizingMask = resolutionButton.autoresizingMask;
    
    [signatureCommentButton retain];
    
    [backgroundView addSubview:signatureCommentButton];
    
    //back button
    //add extra spaces to front of label, cause of button with left arrow
    backButton = [UIButton buttonWithBackgroundAndTitle:[@"  " stringByAppendingString: NSLocalizedString(@"Back", "Back")]
                                              titleFont:[UIFont boldSystemFontOfSize:12]
                                                 target:self
                                               selector:@selector(backFromLink:)
                                                  frame:CGRectMake(0, 0, 25, 30)
                                          addLabelWidth:YES
                                                  image:[UIImage imageNamed:@"BackBarButton.png"]
                                           imagePressed:[UIImage imageNamed:@"BackBarButtonSelected.png"]
                                           leftCapWidth:15.0f
                                          darkTextColor:NO];
    
    [backButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5] forState:UIControlStateNormal];
    backButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    CGRect backButtonFrame = backButton.frame;
    backButtonFrame.origin.x = resolutionButtonFrame.origin.x;
    backButtonFrame.origin.y = resolutionButtonFrame.origin.y;
    backButton.frame = backButtonFrame;
    backButton.autoresizingMask = resolutionButton.autoresizingMask;
    
    [backButton retain];
    
    [backgroundView addSubview:backButton];
    
    
    //info button
    infoButton = [UIButton buttonWithBackgroundAndTitle:NSLocalizedString(@"Information", "Information")
                                              titleFont:[UIFont boldSystemFontOfSize:12]
                                                 target:self
                                               selector:@selector(showInfo:)
                                                  frame:CGRectMake(0, 0, 20, 30)
                                          addLabelWidth:YES
                                                  image:[UIImage imageNamed:@"ButtonSquare.png"]
                                           imagePressed:[UIImage imageNamed:@"ButtonSquareSelected.png"]
                                           leftCapWidth:10.0f
                                          darkTextColor:NO];
    
    [infoButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5] forState:UIControlStateNormal];
    infoButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    CGRect infoButtonFrame = infoButton.frame;
    infoButtonFrame.origin.x = 720 - infoButtonFrame.size.width;
    infoButtonFrame.origin.y = 12.0f;
    infoButton.frame = infoButtonFrame; 
    infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    [infoButton retain];
    
    [backgroundView addSubview:infoButton];

    
    //contentView
    contentView = [[RotateableImageView alloc] initWithImage: [UIImage imageNamed: @"Paper.png"]];
    contentView.portraitImage = [UIImage imageNamed: @"Paper.png"];
    contentView.landscapeImage = [UIImage imageNamed: @"Paper-Landscape.png"];
    contentView.userInteractionEnabled = YES;
    
    CGRect contentViewFrame = contentView.frame;
    contentViewFrame.origin.x = round((backgroundViewFrame.size.width - contentViewFrame.size.width) / 2);
    contentViewFrame.origin.y = 43;
    contentView.frame = contentViewFrame;
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);

    [backgroundView addSubview:contentView];

    //page control
    CGRect pageControlFrame = CGRectMake(0, viewFrame.size.height - 37, viewFrame.size.width, 37);
    PageControl *pageControl = [[[PageControl alloc] initWithFrame: pageControlFrame] autorelease];
    
    pageControl.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);

    [self.view addSubview:pageControl];
    
    //documentInfo
    documentInfoViewController = [[DocumentInfoViewController alloc] init];
    
    CGRect documentInfoFrame = documentInfoViewController.view.frame;
    documentInfoFrame.origin.x = kLeftMargin;
    documentInfoFrame.origin.y = kTopMargin + 40.f;
    documentInfoFrame.size.width = contentViewFrame.size.width - kLeftMargin - kRightMargin;
    documentInfoFrame.size.height = 395;
    
    documentInfoViewController.view.frame = documentInfoFrame;
    
    documentInfoViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    
    documentInfoViewControllerSize = documentInfoFrame.size;
    
    documentInfoViewControllerSize.height = documentInfoFrame.size.height;

    [documentInfoViewController addObserver:self
                                 forKeyPath:@"attachment"
                                    options:0
                                    context:&AttachmentContext];
    
    [documentInfoViewController addObserver:self
                                 forKeyPath:@"link"
                                    options:0
                                    context:&LinkContext];
    
    [contentView addSubview:documentInfoViewController.view];
    
    //attachments
    attachmentsViewController = [[AttachmentsViewController alloc] init];

    CGRect attachmentsFrame = CGRectMake(kLeftMargin, kTopMargin, contentViewFrame.size.width - kLeftMargin - kRightMargin, contentViewFrame.size.height - 2 * kTopMargin);

    attachmentsViewController.view.frame = attachmentsFrame;
    
    attachmentsViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    attachmentsViewController.pageControl = pageControl;

    paintingToolsViewController.delegate = attachmentsViewController;
    
    //default color for attachmentView
    attachmentsViewController.paintingTools = paintingToolsViewController;
    
    [contentView addSubview:attachmentsViewController.view];


    resolutionViewController = [[ResolutionViewController alloc] init];

    resolutionViewController.view.hidden = YES;
    
    CGRect resolutionFrame = resolutionViewController.view.frame;
    resolutionFrame.origin.x = round((contentViewFrame.size.width-resolutionFrame.size.width) / 2);
    resolutionFrame.origin.y = 0;
    resolutionViewController.view.frame = resolutionFrame;

    resolutionViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    [contentView addSubview:resolutionViewController.view];
    
    signatureCommentViewController = [[SignatureCommentViewController alloc] init];
    signatureCommentViewController.view.hidden = YES;
    
    CGRect signatureCommentFrame = signatureCommentViewController.view.frame;
    signatureCommentFrame.origin.x = round((contentViewFrame.size.width-signatureCommentFrame.size.width) / 2);
    signatureCommentFrame.origin.y = 0;
    signatureCommentViewController.view.frame = signatureCommentFrame;
    
    signatureCommentViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);

    [contentView addSubview:signatureCommentViewController.view];
    
    canEdit = YES;

    [self updateContent];

    blockView = [[MBProgressHUD alloc] initWithView:self.view];
	
    blockView.mode = MBProgressHUDModeIndeterminate;
	
    [self.view addSubview:blockView];
	
    blockView.labelText = NSLocalizedString(@"Synchronizing", "Synchronizing");
	
    [[DataSource sharedDataSource] addObserver:self
                                    forKeyPath:@"isSyncing"
                                       options:0
                                       context:&SyncingContext];
    
    [self findAndSetDocumentInFolder];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver: self selector: @selector(documentsChanged:)
			   name: kDocumentFlowDeleted object: nil];

    [nc addObserver: self selector: @selector(documentsChanged:)
			   name: kDocumentFlowUpdated object: nil];
}

#pragma mark - 
#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([attachmentsViewController respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)]) 
        [attachmentsViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [attachmentsViewController release]; attachmentsViewController = nil;
    [clipperViewController removeObserver:self forKeyPath:@"opened"];
    [clipperViewController release]; clipperViewController = nil;
    [documentInfoViewController removeObserver:self forKeyPath:@"attachment"];
    [documentInfoViewController release]; documentInfoViewController = nil;
    [contentView release]; contentView = nil;
    [toolbar release]; toolbar = nil;
    [declineButton release]; declineButton = nil;
    [acceptButton release]; acceptButton = nil;
    [infoButton release]; infoButton = nil;
    [resolutionButton release]; resolutionButton = nil;
    [backButton release]; backButton = nil;
    [signatureCommentButton release]; signatureCommentButton = nil;
    [signatureCommentViewController release]; signatureCommentViewController = nil;
    [blockView release]; blockView = nil;
}

- (void) dealloc
{
    self.document = nil;

    [attachmentsViewController release]; attachmentsViewController = nil;
    [clipperViewController removeObserver:self forKeyPath:@"opened"];
    [clipperViewController release]; clipperViewController = nil;
    [documentInfoViewController removeObserver:self forKeyPath:@"attachment"];
    [documentInfoViewController release]; documentInfoViewController = nil;
    [contentView release]; contentView = nil;
    [toolbar release]; toolbar = nil;
    [declineButton release]; declineButton = nil;
    [acceptButton release]; acceptButton = nil;
    [infoButton release]; infoButton = nil;
    [resolutionButton release]; resolutionButton = nil;
    [backButton release]; backButton = nil;
    [signatureCommentButton release]; signatureCommentButton = nil;
    [signatureCommentViewController release]; signatureCommentViewController = nil;
    [blockView release]; blockView = nil;
    
	[super dealloc];
}
#pragma mark -
#pragma mark Actions

-(void) showInfo:(id) sender
{
    clipperViewController.opened = !clipperViewController.opened;
}

-(void) backFromLink :(id) sender
{
    backButton.hidden = YES;
    [self updateContent];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationDelegate:nil];
    [UIView setAnimationDidStopSelector:nil];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:contentView cache:YES];
    
    attachmentsViewController.attachment = self.document.firstAttachment;
    documentInfoViewController.document = self.document;
    
    [UIView commitAnimations];    
}

-(void) showDocuments:(id) sender
{
    NSArray *folders = [DataSource sharedDataSource].folders;
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
    self.document.statusValue = DocumentStatusDeclined;

    [[DataSource sharedDataSource] commit];
    
    [self moveToArchive];
}

- (void) acceptDocument:(id) sender
{
    self.document.statusValue = DocumentStatusAccepted;
    
    [[DataSource sharedDataSource] commit];

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
        if (resolutionButton.selected && clipperViewController.opened) //hide resolution
            [self showResolution:resolutionButton];

        if (signatureCommentButton.selected && clipperViewController.opened) //hide signature comment
            [self showSignatureComment:signatureCommentButton];
        
        [UIView beginAnimations:OpenClipperAnimationId context:NULL];
        [UIView setAnimationDuration:.5];

        CGRect attachmentsViewOldFrame = attachmentsViewController.view.frame;
        CGRect attachmentsViewFrame = CGRectMake(attachmentsViewOldFrame.origin.x,
                                                 attachmentsViewOldFrame.origin.y+(clipperViewController.opened?1:-1)*documentInfoViewControllerSize.height,
                                                 attachmentsViewOldFrame.size.width, 
                                                 attachmentsViewOldFrame.size.height);
        attachmentsViewController.view.frame = attachmentsViewFrame;

        [UIView commitAnimations];
        infoButton.selected = clipperViewController.opened;

    }
    else if (context == &AttachmentContext)
    {
        if (clipperViewController.opened)
            clipperViewController.opened = NO;
        attachmentsViewController.attachment = documentInfoViewController.attachment;
    } 
    else if (context == &LinkContext)
    {
        if (clipperViewController.opened)
            clipperViewController.opened = NO;
        
        Document *linkedDocument = documentInfoViewController.link;
        
        if (backButton.hidden)
        {
            
            resolutionButton.hidden = YES;
            signatureCommentButton.hidden = YES;
            backButton.hidden = NO;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.5];
            [UIView setAnimationDelegate:nil];
            [UIView setAnimationDidStopSelector:nil];
            
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                                   forView:contentView cache:YES];
            
            attachmentsViewController.attachment = linkedDocument.firstAttachment;
            documentInfoViewController.document = linkedDocument;
            
            [UIView commitAnimations];
        }
        else
        {
            attachmentsViewController.attachment = linkedDocument.firstAttachment;
            documentInfoViewController.document = linkedDocument;
        }
    }
    else if (context == &SyncingContext)
    {
        BOOL isSyncing = [DataSource sharedDataSource].isSyncing;
        
        if (!isSyncing && (self.document == nil)) //set first document if no document
        {
            [self findAndSetDocumentInFolder];
        }
        
        if (isSyncing)
            [blockView show:YES];
        else
            [blockView hide:YES];
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma Private

-(void) showResolution:(id) sender
{
    resolutionButton.selected = !resolutionButton.selected;
    
    if (resolutionButton.selected && clipperViewController.opened)
        clipperViewController.opened = NO;
    
    attachmentsViewController.view.userInteractionEnabled = !resolutionButton.selected;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationTransition:resolutionButton.selected?UIViewAnimationTransitionCurlDown:UIViewAnimationTransitionCurlUp
                           forView:resolutionViewController.view cache:YES];
    
    resolutionViewController.view.hidden = !resolutionButton.selected;
    
    [UIView commitAnimations];
    
}

- (void) showSignatureComment:(id) sender
{
    signatureCommentButton.selected = !signatureCommentButton.selected;

    if (resolutionButton.selected && clipperViewController.opened)
        clipperViewController.opened = NO;
    
    attachmentsViewController.view.userInteractionEnabled = !signatureCommentButton.selected;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationTransition:signatureCommentButton.selected?UIViewAnimationTransitionCurlDown:UIViewAnimationTransitionCurlUp
                           forView:signatureCommentViewController.view cache:YES];
    
    signatureCommentViewController.view.hidden = !signatureCommentButton.selected;
    
    [UIView commitAnimations];
    
}

- (void) createToolbar
{
    [toolbar release];
    
    NSArray *folders = [DataSource sharedDataSource].folders;

    NSUInteger foldersCount = [folders count];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:foldersCount+3];

    for (NSUInteger i = 0; i < foldersCount; i++)
    {
        Folder *f = [folders objectAtIndex:i];
        UIButton *button = [UIButton imageButtonWithTitle:[@"  " stringByAppendingString: f.localizedName]
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

    declineButton = [UIButton buttonWithBackgroundAndTitle:NSLocalizedString(@"Decline", "Decline")
                                                 titleFont:[UIFont boldSystemFontOfSize:12]
                                                    target:self
                                                  selector:@selector(declineDocument:)
                                                     frame:CGRectMake(0, 0, 15, 30)
                                             addLabelWidth:YES
                                                     image:[UIImage imageNamed:@"ButtonSquareBlack.png"]
                                              imagePressed:[UIImage imageNamed:@"ButtonSquareBlackSelected.png"]
                                              leftCapWidth:10.0f
                                             darkTextColor:NO];
    [declineButton retain];
    
    UIBarButtonItem *declineBarButton = [[UIBarButtonItem alloc] initWithCustomView:declineButton];
    [items addObject: declineBarButton];
    [declineBarButton release];

    acceptButton = [UIButton buttonWithBackgroundAndTitle:NSLocalizedString(@"Accept", "Accept")
                                                titleFont:[UIFont boldSystemFontOfSize:12]
                                                   target:self
                                                 selector:@selector(acceptDocument:)
                                                    frame:CGRectMake(0, 0, 15, 30)
                                            addLabelWidth:YES
                                                    image:[UIImage imageNamed:@"ButtonSquareBlack.png"]
                                             imagePressed:[UIImage imageNamed:@"ButtonSquareBlackSelected.png"]
                                             leftCapWidth:10.0f
                                            darkTextColor:NO];
    
    UIBarButtonItem *acceptBarButton = [[UIBarButtonItem alloc] initWithCustomView:acceptButton];
    [items addObject: acceptBarButton];
    [acceptBarButton release];

    toolbar = [[UIToolbar alloc]
                               initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];

    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    toolbar.backgroundColor = [UIColor blackColor];
    
    toolbar.items = items;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
    [self.view addSubview: toolbar];
}
- (void) moveToArchive
{
    [self setCanEdit:NO];
    if (clipperViewController.opened)
        clipperViewController.opened = NO;

    [UIView beginAnimations:ArchiveAnimationId context:NULL];
    [UIView setAnimationDuration:0.75f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStopped:finished:context:)];

#warning inaccurate positioning when move to archive
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        contentView.transform = CGAffineTransformScale (
                                                                           CGAffineTransformMakeTranslation(-200.0, -475.0),
                                                                           0.1,
                                                                           0.1
                                                                           );
        
    else
        contentView.transform = CGAffineTransformScale (
                                                                           CGAffineTransformMakeTranslation(-300.0, -375.0),
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
- (void)animationDidStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (animationID == ArchiveAnimationId)
    {
        contentView.hidden = YES;
        contentView.transform = CGAffineTransformIdentity;
        contentView.hidden = NO;
        [UIView setAnimationDelegate:nil];
        [UIView setAnimationDidStopSelector:nil];
        
        //set first document in current folder
        [self findAndSetDocumentInFolder];
    }
}
-(void) setCanEdit:(BOOL) value
{
    canEdit = value;
    if (canEdit)
    {
        acceptButton.hidden = NO;
        acceptButton.enabled = YES;

        declineButton.hidden = NO;
        declineButton.enabled = YES;
    }
    else
    {
        acceptButton.hidden = YES;
        acceptButton.enabled = NO;

        declineButton.hidden = YES;
        declineButton.enabled = NO;
    }
}
-(void) updateContent
{
    documentInfoViewController.document = self.document;

    attachmentsViewController.attachment = self.document.firstAttachment;

    if (!self.document)
    {
        infoButton.hidden = YES;
        resolutionButton.hidden = YES;
        backButton.hidden = YES;
        signatureCommentButton.hidden = YES;
        [self setCanEdit: NO];
        return;
    }

    infoButton.hidden = NO;
    
    if ([self.document isKindOfClass: [DocumentResolution class]])
    {
        resolutionViewController.document = (DocumentResolution *)self.document;
        resolutionButton.hidden = NO;

        if (!signatureCommentButton.hidden && signatureCommentButton.selected) //hide signature comment
            [self showSignatureComment:signatureCommentButton];
        signatureCommentButton.hidden = YES;
        signatureCommentViewController.document = nil;
    }
    else
    {
        if (!resolutionButton.hidden && resolutionButton.selected) //hide resolution
            [self showResolution:resolutionButton];
        resolutionViewController.document = nil;
        resolutionButton.hidden = YES;
        signatureCommentButton.hidden = NO;
        signatureCommentViewController.document = (DocumentSignature *)self.document;;
    }
    
    backButton.hidden = YES;
    
    [self setCanEdit: ((self.document.statusValue == DocumentStatusDraft || self.document.statusValue == DocumentStatusNew))];
}

- (void) findAndSetDocumentInFolder
{
    NSArray *folders = [DataSource sharedDataSource].folders;
    
    for (Folder *folder in folders)
    {
        for (Folder *filter in folder.filters)
        {
            Document *d = filter.firstDocument;
            if (d)
            {
                self.document = d;
                return;
            }
        }
        
        break; //only for first folder
    }
    self.document = nil;
}

- (void)documentsChanged:(NSNotification*) notification
{
    NSSet *documents = notification.object;
    if ([documents containsObject:self.document])
    {
        if (self.document.isDeleted)
            [self findAndSetDocumentInFolder];
        else
            self.document = self.document;
    }
}
@end
