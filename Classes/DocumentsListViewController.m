    //
    //  MainViewController.m
    //  Meester
    //
    //  Created by Vladimir Solomenchuk on 14.08.10.
    //  Copyright 2010 __MyCompanyName__. All rights reserved.
    //

#import "DocumentsListViewController.h"
#import "DataSource.h"
#import "Document.h"
#import "Folder.h";
#import "UIButton+Additions.h"
#import "Person.h"

#define ROW_HEIGHT 94

static NSString* SyncingContext = @"SyncingContext";

@interface DocumentsListViewController(Private)
- (void) createToolbars;
- (void)updateSyncStatus;
- (void)updateContent;
- (NSString *)sectionNameForDate:(NSDate *) date;
@end


@implementation DocumentsListViewController

#pragma mark -
#pragma mark properties
@synthesize dateFormatter;
@synthesize folder;
@synthesize activityDateFormatter; 
@synthesize activityTimeFormatter;
@synthesize delegate;
@synthesize document;

- (void) setFolder:(Folder *)aFolder
{
    if (folder == aFolder)
        return;
    [folder release];
    folder = [aFolder retain];
    
    [self updateContent];
}

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = ROW_HEIGHT;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"PaperTexture.png"]];
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
    
    [self createToolbars];
    
    NSError *error;
	if (![fetchedResultsController performFetch:&error])
		NSAssert1(NO, @"Unhandled error executing count unread document: %@", [error localizedDescription]);
    
    [[DataSource sharedDataSource] addObserver:self
                                    forKeyPath:@"isSyncing"
                                       options:0
                                       context:&SyncingContext];
    [self updateContent];
}

/*
 http://stackoverflow.com/questions/2339721/hiding-a-uinavigationcontrollers-uitoolbar-during-viewwilldisappear
 only way to avlid back strips around uitableview
 */
- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO];
    if (selectedDocumentIndexPath)
        [self.tableView selectRowAtIndexPath:selectedDocumentIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    NSArray *filters = folder.filters;
    NSUInteger filtersCount = [filters count];
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity: filtersCount];
    for (NSUInteger i=0; i < filtersCount; i++)
    {
        Folder *f = [filters objectAtIndex:i];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:f.localizedName image:f.icon tag:i];
        item.tag = i;
        [toolbarItems addObject:item];
        [item release];
    }
    filtersBar.items = toolbarItems;
    filtersBar.selectedItem = filterIndex == NSNotFound?nil:[toolbarItems objectAtIndex: filterIndex];
    [self updateSyncStatus];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{
	return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
        // Section title is the region name
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    NSArray *objects = [sectionInfo objects];
    Document *doc = [objects objectAtIndex:0];
    return [self sectionNameForDate:doc.strippedDateModified];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DocumentCellIdentifier";
    
        // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
	}
    
        // Set appropriate labels for the cells.
    Document *doc = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = doc.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Author", "Author"), doc.author.fullName];
    cell.imageView.image = doc.isReadValue?[UIImage imageNamed:@"ReadMark.png"]:[UIImage imageNamed:@"UnreadMark.png"];
    return cell;
}

#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.document = [fetchedResultsController objectAtIndexPath:indexPath];
    if ([delegate respondsToSelector:@selector(documentDidChanged:)]) 
        [delegate documentDidChanged:self];
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - 
#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    filterIndex = item.tag;
    Folder *filter;
    if (filterIndex != NSNotFound && [folder.filters count]>filterIndex)
        filter = [folder.filters objectAtIndex: filterIndex];
    else if ([folder.filters count])
        filter = [folder.filters objectAtIndex: 0];
    else
        filter = folder;

    fetchedResultsController.delegate = nil;
    [fetchedResultsController release];
    fetchedResultsController = filter.documents;
    [fetchedResultsController retain];
    fetchedResultsController.delegate = self;
    NSError *error;
	if (![fetchedResultsController performFetch:&error])
		NSAssert1(NO, @"Unhandled error executing count unread document: %@", [error localizedDescription]);

    [self.tableView reloadData];
    
    if (selectedDocumentIndexPath)
        [self.tableView selectRowAtIndexPath:selectedDocumentIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];

}
#pragma mark -
#pragma mark Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &SyncingContext)
    {
        [self updateSyncStatus];
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark -
#pragma mark actions
-(void)refreshDocuments:(id)sender
{
    [[DataSource sharedDataSource] refreshDocuments];
}
-(void)dismiss:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Memory management

-(void) viewDidUnload 
{
	[super viewDidUnload];
    self.dateFormatter = nil;
    [titleLabel release];
    titleLabel = nil;
    [detailsLabel release];
    detailsLabel = nil;
    self.activityDateFormatter = nil;
    self.activityTimeFormatter = nil;
    [selectedDocumentIndexPath release];
    selectedDocumentIndexPath = nil;
    [filtersBar release];
    filtersBar = nil;
    
    [[DataSource sharedDataSource] removeObserver:self
                                       forKeyPath:@"isSyncing"];
    
}

- (void)dealloc 
{
    self.dateFormatter = nil;
    self.folder = nil;
    [titleLabel release];
    titleLabel = nil;
    [detailsLabel release];
    detailsLabel = nil;
    self.activityDateFormatter = nil;
    self.activityTimeFormatter = nil;
    self.delegate = nil;
    self.document =  nil;
    [selectedDocumentIndexPath release];
    selectedDocumentIndexPath = nil;
    [filtersBar release];
    filtersBar = nil;
    [fetchedResultsController release]; fetchedResultsController = nil;

    [[DataSource sharedDataSource] removeObserver:self
                                       forKeyPath:@"isSyncing"];
    [super dealloc];
}
@end

@implementation DocumentsListViewController(Private)
- (void) createToolbars;
{
    //create bottom toolbar
    //http://stackoverflow.com/questions/1072604/whats-the-right-way-to-add-a-toolbar-to-a-uitableview
    
    //Create a refresh button
    UIButton *refreshButton = [UIButton buttonWithBackgroundAndTitle:@""
                                                          titleFont:nil
                                                             target:self
                                                           selector:@selector(refreshDocuments:)
                                                              frame:CGRectMake(0, 0, 30, 30)
                                                      addLabelWidth:NO
                                                              image:[UIImage imageNamed:@"ButtonSquare.png"]
                                                       imagePressed:[UIImage imageNamed:@"ButtonSquareSelected.png"]
                                                       leftCapWidth:10.0f
                                                      darkTextColor:NO];

	[refreshButton setImage:[UIImage imageNamed:@"ButtonRefresh.png"] forState:UIControlStateNormal];

    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    
    self.navigationItem.leftBarButtonItem = refreshBarButton;
    [refreshBarButton release];

    //add extra spaces to front of label, cause of button with left arrow
    UIButton *cancelButton = [UIButton buttonWithBackgroundAndTitle:[@"  " stringByAppendingString:NSLocalizedString(@"Close", "Close")]
                                                          titleFont:[UIFont boldSystemFontOfSize:12]
                                                             target:self
                                                           selector:@selector(dismiss:)
                                                              frame:CGRectMake(0, 0, 25, 30)
                                                      addLabelWidth:YES
                                                              image:[UIImage imageNamed:@"BackBarButton.png"]
                                                       imagePressed:[UIImage imageNamed:@"BackBarButtonSelected.png"]
                                                       leftCapWidth:20.0f
                                                      darkTextColor:NO];
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.rightBarButtonItem = cancelBarButton;
    [cancelBarButton release];
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

    filtersBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, 516, 44)];
    [filtersBar setDelegate:self];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:filtersBar];
    [self setToolbarItems:[NSArray arrayWithObject:barButton] animated:NO];
    [barButton release];
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
        
        //update filter badges
        NSArray *filters = folder.filters;
        NSUInteger filtersCount = [filters count];
        NSArray *toolbarItems = filtersBar.items;
        NSUInteger buttonsCount = [toolbarItems count];
        
        for (NSUInteger i=0; i < buttonsCount; i++)
        {
            UITabBarItem *item = [toolbarItems objectAtIndex: i];

            NSUInteger fi = item.tag;
            
            if (fi >= filtersCount)
            {
                NSLog(@"Invalid filter index: %d", fi);
                continue;
            }
            

            Folder *f = [filters objectAtIndex:fi];

            NSInteger count = f.countUnread;
            item.badgeValue = count>0?[NSString stringWithFormat:@"%d", count]:nil;
        }
    }
    
}

- (NSString *)sectionNameForDate:(NSDate *) date
{
    NSString *result = nil;
    NSDateComponents *dateComponents;
    NSInteger myDay, tzDay;
    
    // Set the calendar's time zone to the default time zone.
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    dateComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    myDay = [dateComponents weekday];
    
    dateComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    tzDay = [dateComponents weekday];
    
    NSRange dayRange = [calendar maximumRangeOfUnit:NSWeekdayCalendarUnit];
    NSInteger maxDay = NSMaxRange(dayRange) - 1;
    
    if (myDay == tzDay)
        result = NSLocalizedString(@"Today", "Today");
    else 
    {
        if ((tzDay - myDay) > 0)
            result = NSLocalizedString(@"Tomorrow", "Tomorrow");
        else
            result = NSLocalizedString(@"Yesterday", "Yesterday");
        // Special cases for days at the end of the week
        if ((myDay == maxDay) && (tzDay == 1))
            result = NSLocalizedString(@"Tomorrow", "Tomorrow");

        if ((myDay == 1) && (tzDay == maxDay))
            result = NSLocalizedString(@"Yesterday", "Yesterday");
    }
    
    if (!result)
        result = [dateFormatter stringFromDate: date];

	return result;
}

- (void)updateContent
{
    //deselect selected row
    if (folder)
    {
        Folder *filter;
        
        //find filter for document
        NSArray *filters = folder.filters;
        NSUInteger filtersCount = [folder.filters count];
        
        if (filtersCount)
        {
            filterIndex = 0;
            for (NSUInteger i=0; i < filtersCount; i++)
            {
                Folder *f = [filters objectAtIndex: i];
                if ([document isKindOfClass: f.entityClass] && [f.predicate evaluateWithObject: document])
                {
                    filterIndex = i;
                    break;
                }
            }
            
            filter = [filters objectAtIndex: filterIndex];
        }
        else
            filter = folder;
        
        fetchedResultsController.delegate = nil;
        [fetchedResultsController release];
        fetchedResultsController = filter.documents;
        [fetchedResultsController retain];
        fetchedResultsController.delegate = self;
        filtersBar.selectedItem = [filtersBar.items objectAtIndex: filterIndex];
    }
    else
        filterIndex = NSNotFound;
    
    titleLabel.text = folder.localizedName;
}
@end