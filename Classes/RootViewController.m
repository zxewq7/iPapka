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
#import "ResolutionViewController.h"
#import "RotateableImageView.h"
#import "PageControlWithMenu.h"

#define LEFT_CONTENT_MARGIN 5.0f
#define RIGHT_CONTENT_MARGIN 5.0f

#define TOP_CONTENT_MARGIN 5.0f
#define BOTTOM_CONTENT_MARGIN 10.0f

#define PAINTING_TOOLS_LEFT_OFFSET 2
#define PAINTING_TOOLS_TOP_OFFSET 33

static NSString* ArchiveAnimationId = @"ArchiveAnimationId";
static NSString* OpenClipperAnimationId = @"OpenClipperAnimationId";

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    CGRect viewFrame = self.view.frame;
    
    [self createToolbar];
    
    //background image
    
    CGRect toolbarFrame = toolbar.bounds;

    RotateableImageView *backgroundView = [[RotateableImageView alloc] initWithImage:[UIImage imageNamed:@"RootBackground.png"]];
    backgroundView.portraitImage = [UIImage imageNamed: @"RootBackground.png"];
    backgroundView.landscapeImage = [UIImage imageNamed: @"RootBackground-Landscape.png"];
    backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight);

    backgroundView.frame = CGRectMake(0, toolbarFrame.origin.y+toolbarFrame.size.height, viewFrame.size.width, backgroundView.frame.size.height);
    [self.view addSubview:backgroundView];
    [backgroundView release];
    
    CGRect viewBounds = self.view.bounds;

    //clipper
    clipperViewController = [[ClipperViewController alloc] init];
    CGSize clipperSize = clipperViewController.view.frame.size;
    CGRect clipperFrame = CGRectMake((viewBounds.size.width-clipperSize.width)/2, 0,clipperSize.width, clipperSize.height);
    clipperViewController.view.frame = clipperFrame;
    clipperViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    
    [clipperViewController addObserver:self
                                 forKeyPath:@"opened"
                                    options:0
                                    context:&ClipperOpenedContext];
    
    contentHeightOffset = toolbarFrame.origin.y+toolbarFrame.size.height+[clipperViewController contentOffset];

    //contentView
    contentView = [[RotateableImageView alloc] initWithImage: [UIImage imageNamed: @"Papers.png"]];
    contentView.portraitImage = [UIImage imageNamed: @"Papers.png"];
    contentView.landscapeImage = [UIImage imageNamed: @"Papers-Landscape.png"];
    contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight);
    
    CGSize contentViewSize = contentView.frame.size;
    
    contentView.frame = CGRectMake((viewBounds.size.width-contentViewSize.width)/2, contentHeightOffset, contentViewSize.width, contentViewSize.height);
    contentView.userInteractionEnabled = YES;

    //attachments view
    CGRect attachmentsViewFrame = CGRectMake(LEFT_CONTENT_MARGIN, TOP_CONTENT_MARGIN, contentViewSize.width - LEFT_CONTENT_MARGIN - RIGHT_CONTENT_MARGIN, contentViewSize.height - TOP_CONTENT_MARGIN - BOTTOM_CONTENT_MARGIN);
    attachmentsViewController = [[AttachmentsViewController alloc] init];
    attachmentsViewController.view.frame = attachmentsViewFrame;
    attachmentsViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight);

    //page control
    CGRect pageControlFrame = CGRectMake(0, viewFrame.size.height - 37, viewFrame.size.width, 37);
    PageControlWithMenu *pageControl = [[PageControlWithMenu alloc] initWithFrame: pageControlFrame];
    
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.backgroundView.image = [UIImage imageNamed: @"PageControlBackground.png"];
    pageControl.backgroundView.frame = CGRectMake(0, 0, pageControlFrame.size.width, 40);
    pageControl.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    pageControl.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);

    attachmentsViewController.pageControl = pageControl;
    [pageControl release];

    //attachmentPicker view
    documentInfoViewController = [[DocumentInfoViewController alloc] init];
    CGRect documentInfoViewControllerFrame = CGRectMake(LEFT_CONTENT_MARGIN, TOP_CONTENT_MARGIN, contentViewSize.width - LEFT_CONTENT_MARGIN - RIGHT_CONTENT_MARGIN, 300);
    documentInfoViewController.view.frame = documentInfoViewControllerFrame;
    documentInfoViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth);
    
    documentInfoViewController.view.alpha = 0.0;
    
    [documentInfoViewController addObserver:self
                                 forKeyPath:@"attachment"
                                    options:0
                                    context:&AttachmentContext];

    paintingToolsViewController = [[PaintingToolsViewController alloc] init];
    CGSize paintingSize = paintingToolsViewController.view.frame.size;
    CGFloat paintingToolsOffsetFromLeftEdge = paintingSize.width - contentView.frame.origin.x+PAINTING_TOOLS_LEFT_OFFSET;
    paintingToolsOffsetFromLeftEdge = paintingToolsOffsetFromLeftEdge<0?0:paintingToolsOffsetFromLeftEdge;
    CGRect paintingToolsFrame = CGRectMake(contentView.frame.origin.x-paintingSize.width+paintingToolsOffsetFromLeftEdge, contentHeightOffset+PAINTING_TOOLS_TOP_OFFSET, paintingSize.width, paintingSize.height);
    paintingToolsViewController.view.frame = paintingToolsFrame;

    paintingToolsViewController.delegate = attachmentsViewController;

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

    [resolutionButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    resolutionButton.titleLabel.shadowOffset = CGSizeMake(0.1, -1.0);

    CGSize resolutionButtonSize = resolutionButton.frame.size;
    CGRect resolutionButtonFrame = CGRectMake(contentView.frame.origin.x, contentHeightOffset - resolutionButtonSize.height, resolutionButtonSize.width, resolutionButtonSize.height);
    resolutionButton.frame = resolutionButtonFrame;
    resolutionButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [resolutionButton retain];

    //add extra spaces to front of label, cause of button with left arrow
    infoButton = [UIButton buttonWithBackgroundAndTitle:[@"  " stringByAppendingString: NSLocalizedString(@"Information", "Information")]
                                              titleFont:[UIFont boldSystemFontOfSize:12]
                                                 target:self
                                               selector:@selector(showInfo:)
                                                  frame:CGRectMake(0, 0, 25, 30)
                                          addLabelWidth:YES
                                                  image:[UIImage imageNamed:@"BackBarButton.png"]
                                           imagePressed:[UIImage imageNamed:@"BackBarButtonSelected.png"]
                                           leftCapWidth:20.0f
                                          darkTextColor:NO];

    [infoButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    infoButton.titleLabel.shadowOffset = CGSizeMake(0.1, -1.0);

    
    CGSize infoButtonSize = infoButton.frame.size;
    CGRect infoButtonFrame = CGRectMake(contentView.frame.origin.x + contentView.frame.size.width - infoButtonSize.width, contentHeightOffset - infoButtonSize.height, infoButtonSize.width, infoButtonSize.height);
    infoButton.frame = infoButtonFrame;
    infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [infoButton retain];
    
    resolutionViewController = [[ResolutionViewController alloc] init];
    CGSize resolutionSize = resolutionViewController.view.frame.size;
    CGRect resolutionFrame = CGRectMake((contentView.frame.size.width-resolutionSize.width)/2, 0, resolutionSize.width, resolutionSize.height);
    resolutionViewController.view.frame = resolutionFrame;
    resolutionViewController.view.hidden = YES;
    resolutionViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
    
    [contentView addSubview: documentInfoViewController.view];
    [contentView addSubview: attachmentsViewController.view];

    [self.view addSubview:paintingToolsViewController.view];
    [self.view addSubview:contentView];
    [contentView addSubview: resolutionViewController.view];
    [self.view addSubview:clipperViewController.view];
    [self.view addSubview:infoButton];
    [self.view addSubview:resolutionButton];
    [self.view addSubview: attachmentsViewController.pageControl];
    
    //to make it over clipper
    [self.view bringSubviewToFront:toolbar];
    

    documentInfoViewController.document = self.document;
    [self setCanEdit: [self.document.isEditable boolValue]];
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
    [infoButton release];
    infoButton = nil;
    [resolutionButton release];
    resolutionButton = nil;
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
    [infoButton release];
    infoButton = nil;
    [resolutionButton release];
    resolutionButton = nil;
    
	[super dealloc];
}
#pragma mark -
#pragma mark Actions

-(void) showInfo: (id) sender
{
    clipperViewController.opened = !clipperViewController.opened;
}

-(void) showResolution:(id) sender
{
    resolutionButton.selected = !resolutionButton.selected;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationTransition:resolutionButton.selected?UIViewAnimationTransitionCurlDown:UIViewAnimationTransitionCurlUp
                           forView:resolutionViewController.view cache:YES];
    
    resolutionViewController.view.hidden = !resolutionButton.selected;
    
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
        [UIView beginAnimations:OpenClipperAnimationId context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStopped:finished:context:)];

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
    toolbar.backgroundColor = [UIColor clearColor];
    
    toolbar.items = items;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
    [self.view addSubview: toolbar];
}
- (void) moveToArchive
{
    [self setCanEdit:NO];
    [UIView beginAnimations:ArchiveAnimationId context:NULL];
    [UIView setAnimationDuration:0.75f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStopped:finished:context:)];

#warning inaccurate positioning when move to archive
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
- (void)animationDidStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if (animationID == ArchiveAnimationId)
    {
        contentView.hidden = YES;
        contentView.transform = CGAffineTransformIdentity;
        contentView.hidden = NO;
        [UIView setAnimationDelegate:nil];
        [UIView setAnimationDidStopSelector:nil];
        [[DataSource sharedDataSource] archiveDocument:self.document];
        self.document = nil;
    }
    else if (animationID == OpenClipperAnimationId)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:contentView cache:YES];
        documentInfoViewController.view.alpha = clipperViewController.opened?1.0:0.0;
        [UIView commitAnimations];
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
@end
