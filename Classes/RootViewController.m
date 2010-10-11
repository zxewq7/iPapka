    //
    //  DocumentViewController.m
    //  Meester
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
#import "PageControlWithMenu.h"
#import "DocumentResolution.h"
#import "RootBackgroundView.h"
#import "RootContentView.h"
#import "SignatureCommentViewController.h"

static NSString* ArchiveAnimationId = @"ArchiveAnimationId";
static NSString* OpenClipperAnimationId = @"OpenClipperAnimationId";

static NSString* ClipperOpenedContext = @"ClipperOpenedContext";
static NSString* AttachmentContext    = @"AttachmentContext";
static NSString* LinkContext          = @"LinkContext";

@interface RootViewController(Private)
- (void) createToolbar;
- (void) moveToArchive;
- (void) setCanEdit:(BOOL) value;
- (void) updateContent;
- (void) showResolution:(id) sender;
- (void) showSignatureComment:(id) sender;
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

    self.document = folder.firstDocument;
}

-(void) setDocument:(Document *) aDocument
{
    if (document == aDocument)
        return;
    
    [document release];
    document = [aDocument retain];
    
    if (!document.isReadValue)
        document.isReadValue = YES;
    [[DataSource sharedDataSource] commit];
    
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

    RootBackgroundView *backgroundView = [[RootBackgroundView alloc] initWithImage:[UIImage imageNamed:@"RootBackground.png"]];
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
    
    CGRect viewBounds = self.view.bounds;

    //clipper
    clipperViewController = [[ClipperViewController alloc] init];
    CGRect clipperFrame = clipperViewController.view.frame;
    clipperFrame.origin.x = (viewBounds.size.width - clipperFrame.size.width)/2;
    clipperFrame.origin.y = 0;
    clipperViewController.view.frame = clipperFrame;
    clipperViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    [clipperViewController addObserver:self
                                 forKeyPath:@"opened"
                                    options:0
                                    context:&ClipperOpenedContext];
    
    contentHeightOffset = toolbarFrame.origin.y+toolbarFrame.size.height+[clipperViewController contentOffset];

    //contentView
    contentView = [[RootContentView alloc] initWithImage: [UIImage imageNamed: @"Paper.png"]];
    contentView.portraitImage = [UIImage imageNamed: @"Paper.png"];
    contentView.landscapeImage = [UIImage imageNamed: @"Paper-Landscape.png"];
    contentView.userInteractionEnabled = YES;

    //attachments view
    attachmentsViewController = [[AttachmentsViewController alloc] init];

    //page control
    CGRect pageControlFrame = CGRectMake(0, viewFrame.size.height - 37, viewFrame.size.width, 37);
    PageControlWithMenu *pageControl = [[PageControlWithMenu alloc] initWithFrame: pageControlFrame];
    
    pageControl.dotNormal = [UIImage imageNamed: @"DotNormal.png"];
    pageControl.dotCurrent = [UIImage imageNamed: @"DotCurrent.png"];
    
    UILabel *pageControlLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    pageControlLabel.backgroundColor = [UIColor clearColor];
    pageControlLabel.font = [UIFont boldSystemFontOfSize: 14];
    pageControlLabel.textColor = [UIColor blackColor];
    pageControlLabel.shadowColor = [UIColor whiteColor];
    pageControlLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    pageControl.label = pageControlLabel;

    [pageControlLabel release];
    
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.backgroundView.image = [UIImage imageNamed: @"PageControlBackground.png"];
    pageControl.backgroundView.frame = CGRectMake(0, 0, pageControlFrame.size.width, 40);
    pageControl.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    pageControl.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);

    attachmentsViewController.pageControl = pageControl;
    [pageControl release];

    //attachmentPicker view
    documentInfoViewController = [[DocumentInfoViewController alloc] init];
    
    [documentInfoViewController addObserver:self
                                 forKeyPath:@"attachment"
                                    options:0
                                    context:&AttachmentContext];

    [documentInfoViewController addObserver:self
                                 forKeyPath:@"link"
                                    options:0
                                    context:&LinkContext];

    paintingToolsViewController = [[PaintingToolsViewController alloc] init];

    paintingToolsViewController.delegate = attachmentsViewController;
    
    //default color for attachmentView
    attachmentsViewController.paintingTools = paintingToolsViewController;

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
    
    [backButton retain];
    
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

    [resolutionButton retain];

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
    
    [signatureCommentButton retain];

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

    
    [infoButton retain];
    
    resolutionViewController = [[ResolutionViewController alloc] init];
    resolutionViewController.view.hidden = YES;
    signatureCommentViewController = [[SignatureCommentViewController alloc] init];
    signatureCommentViewController.view.hidden = YES;
    
    contentView.documentInfo = documentInfoViewController.view;
    contentView.attachments = attachmentsViewController.view;
    contentView.resolution = resolutionViewController.view;
    contentView.signatureComment = signatureCommentViewController.view;

    //paper
    RotateableImageView *paperView = [[RotateableImageView alloc] initWithImage:[UIImage imageNamed:@"Papers.png"]];
    paperView.portraitImage = [UIImage imageNamed: @"Papers.png"];
    paperView.landscapeImage = [UIImage imageNamed: @"Papers-Landscape.png"];

    backgroundView.paper = paperView;
    backgroundView.paintingTools = paintingToolsViewController.view;
    backgroundView.content = contentView;
    backgroundView.resolutionButton = resolutionButton;
    backgroundView.signatureCommentButton = signatureCommentButton;
    backgroundView.infoButton = infoButton;
    backgroundView.backButton = backButton;

    [paperView release];

    [self.view addSubview:clipperViewController.view];
    [self.view addSubview: attachmentsViewController.pageControl];
    
    [self.view bringSubviewToFront: clipperViewController.view];
    [clipperViewController counfigureTapzones];
    [self updateContent];
    
    [backgroundView release];

}

#pragma mark - 
#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [clipperViewController silentClose];
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
}

- (void) dealloc
{
    self.document = nil;
    self.folder = nil;

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
    resolutionButton.hidden = NO;
    backButton.hidden = YES;
    
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
    self.document.statusValue = DocumentStatusDeclined;

    [self moveToArchive];
}

- (void) acceptDocument:(id) sender
{
    self.document.statusValue = DocumentStatusAccepted;

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
        if (resolutionButton.selected) //hide resolution
            [self showResolution:resolutionButton];

        if (signatureCommentButton.selected) //hide signature comment
            [self showSignatureComment:signatureCommentButton];

        
        [UIView beginAnimations:OpenClipperAnimationId context:NULL];
        [UIView setAnimationDuration:.5];

        CGSize documentInfoViewControllerSize = documentInfoViewController.view.frame.size;
        
        CGRect attachmentsViewOldFrame = attachmentsViewController.view.frame;
        CGRect attachmentsViewFrame = CGRectMake(attachmentsViewOldFrame.origin.x,attachmentsViewOldFrame.origin.y+(clipperViewController.opened?1:-1)*documentInfoViewControllerSize.height, attachmentsViewOldFrame.size.width, attachmentsViewOldFrame.size.height);
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

    documentInfoViewController.view.hidden = YES;
    
    [UIView beginAnimations:ArchiveAnimationId context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStopped:finished:context:)];
    
    attachmentsViewController.view.alpha = 0.0;
    
    [UIView commitAnimations];

//    [UIView beginAnimations:ArchiveAnimationId context:NULL];
//    [UIView setAnimationDuration:0.75f];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(animationDidStopped:finished:context:)];

//#warning inaccurate positioning when move to archive
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    
//    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
//        attachmentsViewController.view.transform = CGAffineTransformScale (
//                                                                           CGAffineTransformMakeTranslation(-200.0, -475.0),
//                                                                           0.1,
//                                                                           0.1
//                                                                           );
//        
//    else
//        attachmentsViewController.view.transform = CGAffineTransformScale (
//                                                                           CGAffineTransformMakeTranslation(-300.0, -375.0),
//                                                                           0.1,
//                                                                           0.1
//                                                                           );

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
    
//    [UIView commitAnimations];    
}
- (void)animationDidStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (animationID == ArchiveAnimationId)
    {
//        attachmentsViewController.view.hidden = YES;
//        attachmentsViewController.view.transform = CGAffineTransformIdentity;
//        attachmentsViewController.view.hidden = NO;
//        [UIView setAnimationDelegate:nil];
//        [UIView setAnimationDidStopSelector:nil];
        
        attachmentsViewController.view.alpha = 1.0;
        documentInfoViewController.view.hidden = NO;
        
        [[DataSource sharedDataSource] commit];
        
        //set first document in current folder
        self.document = folder.firstDocument;
    }
}
-(void) setCanEdit:(BOOL) value
{
    if (canEdit == value)
        return;
    canEdit = value;
    if (canEdit)
    {
        acceptButton.hidden = NO;
        acceptButton.enabled = YES;

        declineButton.hidden = NO;
        declineButton.enabled = YES;
        
        paintingToolsViewController.view.hidden = NO;
        paintingToolsViewController.view.userInteractionEnabled = YES;
    }
    else
    {
        acceptButton.hidden = YES;
        acceptButton.enabled = NO;

        declineButton.hidden = YES;
        declineButton.enabled = NO;

        paintingToolsViewController.view.hidden = YES;
        paintingToolsViewController.view.userInteractionEnabled = NO;
    }
}
-(void) updateContent
{
    documentInfoViewController.document = self.document;

    attachmentsViewController.attachment = self.document.firstAttachment;

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
@end
