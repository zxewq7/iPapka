    //
    //  MainViewController.m
    //  Meester
    //
    //  Created by Vladimir Solomenchuk on 14.08.10.
    //  Copyright 2010 __MyCompanyName__. All rights reserved.
    //

#import "DocumentsListViewController.h"
#import "DataSource.h"
#import "DocumentManaged.h"
#import "Folder.h";

#define ROW_HEIGHT 94

@interface DocumentsListViewController(Private)
- (void)documentAdded:(NSNotification *)notification;
- (void)documentsRemoved:(NSNotification *)notification;
- (void)documentUpdated:(NSNotification *)notification;
- (void)updateDocuments:(NSArray *) documents isDeleteDocuments:(BOOL)isDeleteDocuments isDelta:(BOOL)isDelta;
- (void) createToolbars;
- (void)updateSyncStatus;
@end


@implementation DocumentsListViewController

#pragma mark -
#pragma mark properties
@synthesize sections, 
            sectionsOrdered, 
            sectionsOrderedLabels, 
            dateFormatter, 
            sortDescriptors, 
            folder,
            activityDateFormatter, 
            activityTimeFormatter;

- (void) setFolder:(Folder *)aFolder
{
    if (folder == aFolder)
        return;
    [folder release];
    folder = [aFolder retain];
    
        //deselect selected row
    if (folder)
    {
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        if (selectedPath)
            [self.tableView deselectRowAtIndexPath:selectedPath animated:NO];
        
        titleLabel.text = folder.localizedName;
        [self updateDocuments:[[DataSource sharedDataSource] documentsForFolder:folder] isDeleteDocuments:NO isDelta:NO];
    }
}

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = ROW_HEIGHT;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Paper.png"]];
    self.tableView.backgroundView = backgroundView;
    [backgroundView release];
    
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;

    self.activityDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.activityDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.activityDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.activityTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.activityTimeFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.activityTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.sections = [NSMutableDictionary dictionaryWithCapacity:1];
    self.sectionsOrdered = [NSMutableArray arrayWithCapacity:1];
    self.sectionsOrderedLabels = [NSMutableArray arrayWithCapacity:1];
                                  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentAdded:)
                                                 name:@"DocumentAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsRemoved:)
                                                 name:@"DocumentsRemoved" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentUpdated:)
                                                 name:@"DocumentUpdated" object:nil];
    [self createToolbars];
    [self updateSyncStatus];
}

-(void) viewDidUnload {
	[super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.dateFormatter = nil;
    self.sections = nil;
    self.sectionsOrdered = nil;
    self.sectionsOrderedLabels = nil;
    [titleLabel release];
    titleLabel = nil;
    [detailsLabel release];
    detailsLabel = nil;
    self.activityDateFormatter = nil;
    self.activityTimeFormatter = nil;
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        UIImageView *selectedRowBackground = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"DocumentInfoSelectedCell.png"]];
        cell.selectedBackgroundView = selectedRowBackground;
        [selectedRowBackground release];
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.detailTextLabel.highlightedTextColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
	}
    
        // Set appropriate labels for the cells.
    NSArray *documentSection = [self.sections objectForKey:[self.sectionsOrdered objectAtIndex:indexPath.section]];
    DocumentManaged *document = [documentSection objectAtIndex:indexPath.row];
    cell.textLabel.text = document.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Author", "Author"), document.author];
    return cell;
}

#pragma mark -
#pragma mark actions
-(void)refreshDocuments:(id)sender
{
    [[DataSource sharedDataSource] refreshDocuments];
}
-(void)closeSelf:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    /*
//     Create and configure a new detail view controller appropriate for the selection.
//     */
//    
//    UINavigationController *navogationController = [splitViewController.viewControllers objectAtIndex:1];
//    DocumentViewController *detailViewController = [navogationController.viewControllers objectAtIndex:0];
//    
//    NSArray *documentSection = [self.sections objectForKey:[self.sectionsOrdered objectAtIndex:indexPath.section]];
//    DocumentManaged *document = [documentSection objectAtIndex:indexPath.row];
//
//    detailViewController.document = document;
//
//        // Dismiss the popover if it's present.
//    if (popoverController != nil) {
//        [popoverController dismissPopoverAnimated:YES];
//    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    self.sections = nil;
    self.sectionsOrdered = nil;
    self.sectionsOrderedLabels = nil;
    self.dateFormatter = nil;
    self.sortDescriptors = nil;
    self.folder = nil;
    [titleLabel release];
    titleLabel = nil;
    [detailsLabel release];
    detailsLabel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.activityDateFormatter = nil;
    self.activityTimeFormatter = nil;
    [super dealloc];
}
@end

@implementation DocumentsListViewController(Private)
- (void)updateDocuments:(NSArray *) documents isDeleteDocuments:(BOOL)isDeleteDocuments isDelta:(BOOL)isDelta;
{
    if (!isDelta) //just clear all
    {
        NSUInteger length = [sections count];
        [sections removeAllObjects];
        [sectionsOrdered removeAllObjects];
        [sectionsOrderedLabels removeAllObjects];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, length)] withRowAnimation:UITableViewRowAnimationTop];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSPredicate *filter = folder.predicate;
    Class entityClass = folder.entityClass;
    
    for (DocumentManaged *document in documents) 
    {
        if (![document isKindOfClass:entityClass] || (filter && ![filter evaluateWithObject:document]))
            continue;
        
        NSDate *documentDate = document.dateModified;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:documentDate];
        NSDate *documentSection = [calendar dateFromComponents:comps];
        NSUInteger sectionIndex = [self.sectionsOrdered indexOfObject:documentSection];
        
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
                        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex: sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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
                    if ([documentSection compare: section] == NSOrderedDescending) 
                    {
                        insertIndex = i;
                        break;
                    }
                }
                if (insertIndex == NSNotFound)
                {
                    [self.sections setObject:[NSMutableArray arrayWithObject:document] forKey:documentSection];
                    [self.sectionsOrdered addObject:documentSection];
                    [self.sectionsOrderedLabels addObject: [self.dateFormatter stringFromDate:documentSection]];
                    insertIndex = [self.sectionsOrdered count]-1;
                }
                else 
                {
                    [self.sections setObject:[NSMutableArray arrayWithObject:document] forKey:documentSection];
                    [self.sectionsOrdered insertObject:documentSection atIndex:insertIndex];
                    [self.sectionsOrderedLabels insertObject: [self.dateFormatter stringFromDate:documentSection] atIndex:insertIndex];
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
                    DocumentManaged *doc = [sectionDocuments objectAtIndex:i];
                    if ([document isEqual:doc]) 
                    {
                        [sectionDocuments replaceObjectAtIndex:i withObject:document];

                        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
                        updated = YES;
                        break;
                    }
                    else if ([document.dateModified compare:doc.dateModified] == NSOrderedDescending)
                        possibleInsertIndex = i;
                }
                if (!updated) //insert document
                {
                    if (possibleInsertIndex == NSNotFound)
                    {
                        [sectionDocuments addObject: document];
                        possibleInsertIndex = [sectionDocuments count]-1;
                    }
                    else
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
                    NSUInteger docIndex = [sectionDocuments indexOfObject: document];
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
- (void)documentAdded:(NSNotification *)notification
{
    Document *document = notification.object;
    [self updateDocuments: [NSArray arrayWithObject:document] isDeleteDocuments:NO isDelta:YES];
}

- (void)documentsRemoved:(NSNotification *)notification
{
    NSArray *documents = notification.object;
    [self updateDocuments: documents isDeleteDocuments:YES isDelta:YES];
}

- (void)documentUpdated:(NSNotification *)notification
{
    Document *document = notification.object;
    [self updateDocuments: [NSArray arrayWithObject:document] isDeleteDocuments:NO isDelta:YES];
}

- (void) createToolbars;
{
    //create bottom toolbar
    //http://stackoverflow.com/questions/1072604/whats-the-right-way-to-add-a-toolbar-to-a-uitableview
    
    //Create a button 
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDocuments:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeSelf:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    //http://www.developers-life.com/customizing-uinavigationbar.html
    UIView *containerView =[[UIView alloc] initWithFrame:CGRectMake(0, 170, 300, 44)];
    
    CGSize containerSize = containerView.frame.size;
    
    CGRect titleFrame = CGRectMake(0, 5.0, containerSize.width, 20);
    titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    
    CGRect detailsFrame = CGRectMake(0, 25.0, containerSize.width, 20);
    detailsLabel = [[UILabel alloc] initWithFrame: detailsFrame];
    detailsLabel.backgroundColor = [UIColor clearColor];
    detailsLabel.font = [UIFont boldSystemFontOfSize:12.0];
    detailsLabel.textAlignment = UITextAlignmentCenter;
    detailsLabel.textColor = [UIColor whiteColor];

    [containerView addSubview: titleLabel];
    [containerView addSubview: detailsLabel];
    
    self.navigationItem.titleView = containerView;
    
    [containerView release];
    
    NSArray *filters = folder.filters;
    NSUInteger filtersCount = [filters count];
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity: filtersCount];
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, 516, 44)];
    DataSource *ds = [DataSource sharedDataSource];
    for (NSUInteger i=0; i < filtersCount; i++)
    {
        Folder *f = [filters objectAtIndex:i];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:f.localizedName image:f.icon tag:i];
        NSInteger count = [ds countUnreadDocumentsForFolder: f];
        item.badgeValue = count>0?[NSString stringWithFormat:@"%d", count]:nil;
        [toolbarItems addObject:item];
        [item release];
    }
    tabBar.items = toolbarItems;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:tabBar];
    [self setToolbarItems:[NSArray arrayWithObject:barButton] animated:NO];
    [barButton release];
    [tabBar release];
}

- (void)updateSyncStatus
{
    DataSource *ds = [DataSource sharedDataSource];
    if (ds.isSyncing) 
        detailsLabel.text = NSLocalizedString(@"Synchronizing", "Synchronizing");
    else
    {
        NSDate *lastSynced = ds.lastSynced;
        if (lastSynced)
            detailsLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Synchronized", "Synchronized"), [self.activityTimeFormatter stringFromDate:lastSynced], [self.activityDateFormatter stringFromDate:lastSynced]];
    }
    
}
@end