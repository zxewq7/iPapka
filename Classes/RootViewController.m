    //
    //  MainViewController.m
    //  Meester
    //
    //  Created by Vladimir Solomenchuk on 14.08.10.
    //  Copyright 2010 __MyCompanyName__. All rights reserved.
    //

#import "RootViewController.h"
#import "DocumentViewController.h"
#import "LNDataSource.h"
#import "Document.h"
#import "DocumentCell.h"
#import "SegmentedLabel.h";
#import "Folder.h";

#define ROW_HEIGHT 94

@interface RootViewController(Private)
- (void)documentsAdded:(NSNotification *)notification;
- (void)documentsRemoved:(NSNotification *)notification;
- (void)documentsUpdated:(NSNotification *)notification;
- (void)documentsListWillRefreshed:(NSNotification *)notification;
- (void)documentsListDidRefreshed:(NSNotification *)notification;
- (void)updateDocuments:(NSArray *) documents isDeleteDocuments:(BOOL)isDeleteDocuments;
- (void)setActivity:(BOOL) isProgress message:(NSString *) aMessage, ...;
- (void)createToolbar;
@end


@implementation RootViewController

#pragma mark -
#pragma mark properties
@synthesize popoverController, 
            splitViewController, 
            rootPopoverButtonItem, 
            sections, 
            sectionsOrdered, 
            sectionsOrderedLabels, 
            dateFormatter, 
            sortDescriptors, 
            activityIndicator, 
            activityLabel,
            activityDateFormatter,
            activityTimeFormatter,
            folder;

- (void) setFolder:(Folder *)aFolder
{
    if (folder == aFolder)
        return;
    [folder release];
    folder = [aFolder retain];
    self.title = folder.localizedName;
    [self updateDocuments:[[[LNDataSource sharedLNDataSource] documents] allValues] isDeleteDocuments:NO];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = ROW_HEIGHT;
    
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateFormatter setDateFormat:@"dd MMMM yyyy"];
    
    self.sections = [NSMutableDictionary dictionaryWithCapacity:1];
    self.sectionsOrdered = [NSMutableArray arrayWithCapacity:1];
    self.sectionsOrderedLabels = [NSMutableArray arrayWithCapacity:1];
    self.activityDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.activityDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.activityDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.activityTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.activityTimeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.activityTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
                                  
    [self updateDocuments: [[LNDataSource sharedLNDataSource].documents allValues] isDeleteDocuments:NO];
    
    
        // Set the content size for the popover: there are just two rows in the table view, so set to rowHeight*2.
    self.contentSizeForViewInPopover = CGSizeMake(310.0, self.tableView.rowHeight*2.0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsAdded:)
                                                 name:@"DocumentsAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsRemoved:)
                                                 name:@"DocumentsRemoved" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsUpdated:)
                                                 name:@"DocumentsUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsListWillRefreshed:)
                                                 name:@"DocumentsListWillRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsListDidRefreshed:)
                                                 name:@"DocumentsListDidRefreshed" object:nil];
        // create folders button
        //http://stackoverflow.com/questions/227078/creating-a-left-arrow-button-like-uinavigationbars-back-style-on-a-uitoolbar/3426793#3426793
//    UIButton* foldersButton = [UIButton buttonWithType:101]; // left-pointing shape!
//    [foldersButton addTarget:self action:@selector(showFolders:) forControlEvents:UIControlEventTouchUpInside];
//    [foldersButton setTitle:NSLocalizedString(@"Folders", "Folders") forState:UIControlStateNormal];
//    // create button item -- note that UIButton subclasses UIView
//    UIBarButtonItem* foldersItem = [[UIBarButtonItem alloc] initWithCustomView:foldersButton];
//    self.navigationItem.leftBarButtonItem = foldersItem;
    [self createToolbar];
}

-(void) viewDidUnload {
	[super viewDidUnload];
	
	self.splitViewController = nil;
	self.rootPopoverButtonItem = nil;
}

#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {
    
        // Keep references to the popover controller and the popover button, and tell the detail view controller to show the button.
    barButtonItem.title = NSLocalizedString(@"Folders", "Folders");
    self.popoverController = pc;
    self.rootPopoverButtonItem = barButtonItem;
        //    UIViewController <SubstitutableDetailViewController> *detailViewController = [splitViewController.viewControllers objectAtIndex:1];
        //    [detailViewController showRootPopoverButtonItem:rootPopoverButtonItem];
}


- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
        // Nil out references to the popover controller and the popover button, and tell the detail view controller to hide the button.
        //    UIViewController <SubstitutableDetailViewController> *detailViewController = [splitViewController.viewControllers objectAtIndex:1];
        //    [detailViewController invalidateRootPopoverButtonItem:rootPopoverButtonItem];
    barButtonItem.title = NSLocalizedString(@"Folders", "Folders");
    self.popoverController = nil;
    self.rootPopoverButtonItem = nil;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return [self.sectionsOrderedLabels count];
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
        // Number of rows is the number of time zones in the region for the specified section
    NSArray *documentSection = [self.sections objectForKey:[self.sectionsOrdered objectAtIndex:section]];
	return [documentSection count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
        // Section title is the region name
	NSString *documentSectionLabel = [self.sectionsOrderedLabels objectAtIndex:section];
	return documentSectionLabel;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DocumentCellIdentifier";
    
        // Dequeue or create a cell of the appropriate type.
    DocumentCell *cell = (DocumentCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[DocumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.frame = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
	}
    
        // Set appropriate labels for the cells.
    NSArray *documentSection = [self.sections objectForKey:[self.sectionsOrdered objectAtIndex:indexPath.section]];
    Document *document = [documentSection objectAtIndex:indexPath.row];
    [cell setDocument: document];
    return cell;
}


#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     Create and configure a new detail view controller appropriate for the selection.
     */
        //    NSUInteger row = indexPath.row;
    
        //    UIViewController <SubstitutableDetailViewController> *detailViewController = nil;
        //    
        //    if (row == 0) {
        //        FirstDetailViewController *newDetailViewController = [[FirstDetailViewController alloc] initWithNibName:@"FirstDetailView" bundle:nil];
        //        detailViewController = newDetailViewController;
        //    }
        //    
        //    if (row == 1) {
        //        SecondDetailViewController *newDetailViewController = [[SecondDetailViewController alloc] initWithNibName:@"SecondDetailView" bundle:nil];
        //        detailViewController = newDetailViewController;
        //    }
    
        //    DocumentViewController *detailViewController = [[DocumentViewController alloc] initWithNibName:@"DocumentViewController" bundle:nil];
        //    
        //        // Update the split view controller's view controllers array.
        //    NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.navigationController, detailViewController, nil];
        //    splitViewController.viewControllers = viewControllers;
        //    [viewControllers release];
        //    
        //        // Dismiss the popover if it's present.
        //    if (popoverController != nil) {
        //        [popoverController dismissPopoverAnimated:YES];
        //    }
    
        // Configure the new view controller's popover button (after the view has been displayed and its toolbar/navigation bar has been created).
        //    if (rootPopoverButtonItem != nil) {
        //        [detailViewController showRootPopoverButtonItem:self.rootPopoverButtonItem];
        //    }
    
        //    [detailViewController release];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    self.popoverController = nil;
    self.rootPopoverButtonItem = nil;
    
    self.sections = nil;
    self.sectionsOrdered = nil;
    self.sectionsOrderedLabels = nil;
    self.dateFormatter = nil;
    self.sortDescriptors = nil;
    self.activityIndicator = nil;
    self.activityLabel = nil;
    self.activityDateFormatter = nil;
    self.activityTimeFormatter = nil;
    self.folder = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark actions
-(void)refreshDocuments:(id)sender
{
    [[LNDataSource sharedLNDataSource] refreshDocuments];
}

-(void)showFolders:(id)sender
{
//    DocumentViewController *detail = [[[DocumentViewController alloc] initWithNibName:@"DocumentViewController" bundle:nil] autorelease];
//    FoldersViewController *root = [[[FoldersViewController alloc] init] autorelease];
//
//    UINavigationController *rootNav = [[[UINavigationController alloc] initWithRootViewController:root]autorelease];
//    
//    self.splitViewController.delegate = root;
//    self.splitViewController.viewControllers = [NSArray arrayWithObjects:rootNav, detail, nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

@implementation RootViewController(Private)
- (void)updateDocuments:(NSArray *) documents isDeleteDocuments:(BOOL)isDeleteDocuments
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSPredicate *filter = folder.predicate;
    for (Document *document in documents) 
    {
            //skip not loaded documents
        if (![filter evaluateWithObject:document])
            continue;
        NSUInteger sectionIndex = [self.sectionsOrdered indexOfObject:document.date];
        NSDate *documentDate = document.date;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:documentDate];
        NSDate *documentSection = [calendar dateFromComponents:comps];
        if (isDeleteDocuments)
        {
            if (sectionIndex != NSNotFound) 
            {
                NSMutableArray *sectionDocuments = [self.sections objectForKey:documentSection];
                NSUInteger documentIndex = [sectionDocuments indexOfObject:document];
                if (documentIndex != NSNotFound) 
                {
                    if ([sectionDocuments count] == 1) //remove empty section
                    {
                        [self.sections removeObjectForKey:documentSection];
                        [self.sectionsOrdered removeObject:documentSection];
                        [self.sectionsOrderedLabels removeObject:[self.dateFormatter stringFromDate:documentSection]];
                        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex: 0] withRowAnimation:UITableViewRowAnimationFade];
                    }
                    else
                    {
                        NSIndexPath *path = [NSIndexPath indexPathForRow:documentIndex inSection:sectionIndex];
                        [sectionDocuments removeObjectAtIndex:documentIndex];
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            }
        }
        else
        {
            if (sectionIndex == NSNotFound) //new section
            {
                NSUInteger length = [self.sectionsOrdered count];
                NSUInteger insertIndex = NSNotFound;
                for (NSUInteger i=0; i < length; i++) 
                {
                    NSDate *section = [self.sectionsOrdered objectAtIndex:i];
                    if ([documentSection earlierDate:section]) 
                    {
                        insertIndex = i;
                        break;
                    }
                }
                if (insertIndex == NSNotFound)
                {
                    [self.sectionsOrdered addObject:documentSection];
                    [self.sectionsOrderedLabels addObject: [self.dateFormatter stringFromDate:documentSection]];
                    [self.sections setObject:[NSMutableArray arrayWithObject:document] forKey:documentSection];
                    insertIndex = [self.sectionsOrdered count]-1;
                }
                else 
                {
                    [self.sectionsOrdered insertObject:documentSection atIndex:insertIndex];
                    [self.sectionsOrderedLabels insertObject: [self.dateFormatter stringFromDate:documentSection] atIndex:insertIndex];
                    [self.sections setObject:[NSMutableArray arrayWithObject:document] forKey:documentSection];
                }
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex: insertIndex] withRowAnimation:UITableViewRowAnimationFade];
                sectionIndex = insertIndex;
            }
            else //update section documents
            {
                NSMutableArray *sectionDocuments = [self.sections objectForKey:documentSection];
                NSUInteger length = [sectionDocuments count];
                NSUInteger possibleInsertIndex = NSNotFound;
                BOOL updated = NO;
                for (NSUInteger i=0; i < length; i++) 
                {
                    Document *doc = [sectionDocuments objectAtIndex:i];
                    if ([document isEqual:doc]) 
                    {
                        [sectionDocuments replaceObjectAtIndex:i withObject:document];

                        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
                        updated = YES;
                        break;
                    }
                    else if (possibleInsertIndex == NSNotFound && [document.date earlierDate:doc.date])
                        possibleInsertIndex = i;
                }
                if (!updated && possibleInsertIndex != NSNotFound) //insert document
                {
                    [sectionDocuments insertObject: document atIndex:possibleInsertIndex];
                    NSIndexPath *path = [NSIndexPath indexPathForRow:possibleInsertIndex inSection:sectionIndex];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
                //remove possible dublicates
                NSUInteger length = [self.sectionsOrdered count];
                for (NSUInteger i=0;i < length; i++) 
                {
                    if (sectionIndex == i) //skip updated section
                        continue;
                    NSDate *section = [self.sectionsOrdered objectAtIndex:i];
                    NSMutableArray *sectionDocuments = [self.sections objectForKey:section];
                    NSUInteger docIndex = [sectionDocuments indexOfObject:document];
                    if (docIndex != NSNotFound)
                    {
                        if ([sectionDocuments count] == 1) //remove section
                        {
                            NSDate *docSection = [self.sectionsOrdered objectAtIndex:i];
                            [self.sections removeObjectForKey:docSection];
                            [self.sectionsOrderedLabels removeObjectAtIndex:i];
                            [self.sectionsOrdered removeObjectAtIndex:i];
                            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex: i] withRowAnimation:UITableViewRowAnimationFade];
                        }
                        else
                        {
                            [sectionDocuments removeObjectAtIndex:docIndex];
                            NSIndexPath *path = [NSIndexPath indexPathForRow:docIndex inSection:i];
                            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
                        }
                        break;
                    }
            }
        }
    }
}
- (void)documentsAdded:(NSNotification *)notification
{
    NSArray *documents = notification.object;
    [self updateDocuments: documents isDeleteDocuments:NO];
}

- (void)documentsRemoved:(NSNotification *)notification
{
    NSArray *documents = notification.object;
    [self updateDocuments: documents isDeleteDocuments:YES];
}

- (void)documentsUpdated:(NSNotification *)notification
{
    NSArray *documents = notification.object;
    [self updateDocuments: documents isDeleteDocuments:NO];
}

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
    
    
    [self.navigationController setToolbarHidden:NO];
    
}
@end
