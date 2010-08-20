//
//  MasterViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 19.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "SegmentedLabel.h"
#import "DataSource.h"

@interface MasterViewController(Private)
- (void)documentsListDidRefreshed:(NSNotification *)notification;
- (void)documentsListWillRefreshed:(NSNotification *)notification;
- (void) createToolbar;
@end

@implementation MasterViewController
@synthesize activityIndicator, 
            activityLabel,
            activityDateFormatter,
            activityTimeFormatter;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsListWillRefreshed:)
                                                 name:@"DocumentsListWillRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsListDidRefreshed:)
                                                 name:@"DocumentsListDidRefreshed" object:nil];
    self.activityDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.activityDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.activityDateFormatter setTimeStyle:NSDateFormatterNoStyle];

    self.activityTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.activityTimeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.activityTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    [self createToolbar];
}

    /*
        http://stackoverflow.com/questions/2339721/hiding-a-uinavigationcontrollers-uitoolbar-during-viewwilldisappear
        only way to avlid back strips around uitableview
     */
- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO];
}

#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        //fix labels colors for popup
    UIColor *textColor;
    UIColor *shadowColor;
    CGSize  shadowOffset;
    switch (interfaceOrientation) {
        case UIDeviceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:    
            textColor = [UIColor whiteColor];
            shadowColor = [UIColor clearColor];
            shadowOffset = CGSizeMake(0.0, 0.0);
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:    
        default:
            textColor = [UIColor colorWithRed:0.350 green:0.375 blue:0.404 alpha:1.000];
            shadowColor = [UIColor whiteColor];
            shadowOffset = CGSizeMake(0.0, 1.0);
            break;
    }

    NSArray *labels = activityLabel.labels;
    for (UILabel *label in labels) 
    {
        label.textColor = textColor;
        label.shadowColor = shadowColor;
        label.shadowOffset = shadowOffset;
    }
    
    
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    self.activityIndicator = nil;
    self.activityLabel = nil;
    self.activityDateFormatter = nil;
    self.activityTimeFormatter = nil;
    [super dealloc];
}
- (void)setActivity:(BOOL) isProgress message:(NSString *) aMessage, ...
{
    va_list args;
    va_start(args, aMessage);
    NSMutableArray *texts = [NSMutableArray arrayWithCapacity:3];
    for (NSString *arg = aMessage; arg != nil; arg = va_arg(args, NSString*))
    {
        if (![arg isKindOfClass:[NSString class]])
            break;
        
        [texts addObject:[arg stringByAppendingString:@" "]];
    }
    va_end(args);
    
    
    self.activityLabel.texts = texts;
    
    if (isProgress)
        [self.activityIndicator startAnimating];
    else
        [self.activityIndicator stopAnimating];
}

#pragma mark -
#pragma mark actions
-(void)refreshDocuments:(id)sender
{
    [[DataSource sharedDataSource] refreshDocuments];
}
@end

@implementation MasterViewController(Private)
- (void)documentsListDidRefreshed:(NSNotification *)notification
{
    NSString *error = notification.object;
    if (error)
        [self setActivity:NO message:error, nil];
    else
    {
        NSDate *now = [NSDate date];
        [self setActivity:NO message: NSLocalizedString(@"Synchronized", "Synchronized"), 
         [self.activityDateFormatter stringFromDate:now], 
         [self.activityTimeFormatter stringFromDate:now],
         nil];
    }
    
}

- (void)documentsListWillRefreshed:(NSNotification *)notification
{
    [self setActivity:YES message:NSLocalizedString(@"Synchronizing", "Synchronizing"), nil];
}

- (void) createToolbar
{
        //create bottom toolbar
        //http://stackoverflow.com/questions/1072604/whats-the-right-way-to-add-a-toolbar-to-a-uitableview
    
        //Create a button 
        //    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(info_clicked:)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDocuments:)];
    
        //activity view
        //http://stackoverflow.com/questions/333441/adding-a-uilabel-to-a-uitoolbar
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];    
    activity.hidesWhenStopped = YES;
    self.activityIndicator = activity;
    
    UIBarButtonItem *activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:activity];
    
        //activity label
    SegmentedLabel *aLabel = [[SegmentedLabel alloc] initWithFrame:CGRectMake(0, 0, 235, 20)];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor colorWithRed:0.350 green:0.375 blue:0.404 alpha:1.000];;
    label1.shadowColor = [UIColor whiteColor];
    label1.shadowOffset = CGSizeMake(0.0, 1.0);
    label1.font = [UIFont boldSystemFontOfSize:13];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor colorWithRed:0.350 green:0.375 blue:0.404 alpha:1.000];;
    label2.shadowColor = [UIColor whiteColor];
    label2.shadowOffset = CGSizeMake(0.0, 1.0);
    label2.font = [UIFont systemFontOfSize:13];
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    label3.backgroundColor = [UIColor clearColor];
    label3.textColor = [UIColor colorWithRed:0.350 green:0.375 blue:0.404 alpha:1.000];;
    label3.shadowColor = [UIColor whiteColor];
    label3.shadowOffset = CGSizeMake(0.0, 1.0);
    label3.font = [UIFont boldSystemFontOfSize:13];
    
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.labels = [NSArray arrayWithObjects:label1, label2, label3, nil];
    self.activityLabel = aLabel;
    UIBarButtonItem *activityLabelButton = [[UIBarButtonItem alloc] initWithCustomView:aLabel];
    
    [self setToolbarItems:[NSArray arrayWithObjects:refreshButton, activityIndicatorButton, activityLabelButton, nil] animated:YES];
    
    [activityIndicatorButton release];
    [activity release];
    [activityLabelButton release];
    [aLabel release];
    [refreshButton release];
}
@end