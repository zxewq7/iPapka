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
#import "UIButton+Additions.h"
#import "PersonManaged.h"

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
@synthesize sections; 
@synthesize sectionsOrdered;
@synthesize sectionsOrderedLabels;
@synthesize dateFormatter;
@synthesize sortDescriptors;
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
    
        //deselect selected row
    if (folder)
    {
        titleLabel.text = folder.localizedName;
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
        
        [self updateDocuments:[[DataSource sharedDataSource] documentsForFolder:filter] isDeleteDocuments:NO isDelta:NO];
        filtersBar.selectedItem = [filtersBar.items objectAtIndex: filterIndex];
    }
    else
        filterIndex = NSNotFound;
    
    titleLabel.text = folder.localizedName;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsListWillRefreshed:)
                                                 name:@"DocumentsListWillRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsListDidRefreshed:)
                                                 name:@"DocumentsListDidRefreshed" object:nil];
    [self createToolbars];
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
    [selectedDocumentIndexPath release];
    selectedDocumentIndexPath = nil;
    [filtersBar release];
    filtersBar = nil;
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
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
	}
    
        // Set appropriate labels for the cells.
    NSArray *documentSection = [self.sections objectForKey:[self.sectionsOrdered objectAtIndex:indexPath.section]];
    DocumentManaged *doc = [documentSection objectAtIndex:indexPath.row];
    cell.textLabel.text = doc.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Author", "Author"), doc.author.fullName];
    cell.imageView.image = doc.isReadValue?[UIImage imageNamed:@"ReadMark.png"]:[UIImage imageNamed:@"UnreadMark.png"];
    return cell;
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

    
    [self updateDocuments:[[DataSource sharedDataSource] documentsForFolder:filter] isDeleteDocuments:NO isDelta:NO];
    if (selectedDocumentIndexPath)
        [self.tableView selectRowAtIndexPath:selectedDocumentIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];

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

#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *documentSection = [self.sections objectForKey:[self.sectionsOrdered objectAtIndex:indexPath.section]];
    self.document = [documentSection objectAtIndex:indexPath.row];
    if ([delegate respondsToSelector:@selector(documentDidChanged:)]) 
        [delegate documentDidChanged:self];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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
    self.delegate = nil;
    self.document =  nil;
    [selectedDocumentIndexPath release];
    selectedDocumentIndexPath = nil;
    [filtersBar release];
    filtersBar = nil;
    
    [super dealloc];
}
@end

@implementation DocumentsListViewController(Private)
- (void)updateDocuments:(NSArray *) documents isDeleteDocuments:(BOOL)isDeleteDocuments isDelta:(BOOL)isDelta;
{
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath)
        [self.tableView deselectRowAtIndexPath:selectedPath animated:NO];

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
    [selectedDocumentIndexPath release];
    selectedDocumentIndexPath = nil;
    
    for (DocumentManaged *doc in documents) 
    {
        if (![doc isKindOfClass:entityClass] || (filter && ![filter evaluateWithObject:doc]))
            continue;
        
        NSDate *documentDate = doc.dateModified;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:documentDate];
        NSDate *documentSection = [calendar dateFromComponents:comps];
        NSUInteger sectionIndex = [self.sectionsOrdered indexOfObject:documentSection];
        NSIndexPath *documentIndexPath = nil;
        
        if (isDeleteDocuments)
        {
            if (sectionIndex != NSNotFound) 
            {
                NSMutableArray *sectionDocuments = [self.sections objectForKey:documentSection];
                NSUInteger documentIndex = [sectionDocuments indexOfObject: doc];
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
                    [self.sections setObject:[NSMutableArray arrayWithObject: doc] forKey:documentSection];
                    [self.sectionsOrdered addObject:documentSection];
                    [self.sectionsOrderedLabels addObject: [self.dateFormatter stringFromDate:documentSection]];
                    insertIndex = [self.sectionsOrdered count]-1;
                }
                else 
                {
                    [self.sections setObject:[NSMutableArray arrayWithObject: doc] forKey:documentSection];
                    [self.sectionsOrdered insertObject:documentSection atIndex:insertIndex];
                    [self.sectionsOrderedLabels insertObject: [self.dateFormatter stringFromDate:documentSection] atIndex:insertIndex];
                }
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex: insertIndex] withRowAnimation:UITableViewRowAnimationFade];
                sectionIndex = insertIndex;
                documentIndexPath = [NSIndexPath indexPathForRow:0 inSection:sectionIndex];
            }
            else //update section documents
            {
                NSMutableArray *sectionDocuments = [self.sections objectForKey:documentSection];
                NSUInteger length = [sectionDocuments count];
                NSUInteger possibleInsertIndex = NSNotFound;
                BOOL updated = NO;
                for (NSUInteger i=0; i < length; i++) 
                {
                    DocumentManaged *docUpdated = [sectionDocuments objectAtIndex:i];
                    if ([doc isEqual: docUpdated]) 
                    {
                        [sectionDocuments replaceObjectAtIndex:i withObject:doc];

                        documentIndexPath = [NSIndexPath indexPathForRow:i inSection:sectionIndex];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject: documentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                        updated = YES;
                        break;
                    }
                    else if ([doc.dateModified compare: docUpdated.dateModified] == NSOrderedDescending)
                        possibleInsertIndex = i;
                }
                if (!updated) //insert document
                {
                    if (possibleInsertIndex == NSNotFound)
                    {
                        [sectionDocuments addObject: doc];
                        possibleInsertIndex = [sectionDocuments count]-1;
                    }
                    else
                        [sectionDocuments insertObject: doc atIndex:possibleInsertIndex];
                    
                    documentIndexPath = [NSIndexPath indexPathForRow:possibleInsertIndex inSection:sectionIndex];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject: documentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
                    NSUInteger docIndex = [sectionDocuments indexOfObject: doc];
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
        if (!selectedDocumentIndexPath && [self.document isEqual: doc] )
            selectedDocumentIndexPath = [documentIndexPath retain];
    }
}
- (void)documentAdded:(NSNotification *)notification
{
    Document *doc = notification.object;
    [self updateDocuments: [NSArray arrayWithObject: doc] isDeleteDocuments:NO isDelta:YES];
}

- (void)documentsRemoved:(NSNotification *)notification
{
    NSArray *documents = notification.object;
    [self updateDocuments: documents isDeleteDocuments:YES isDelta:YES];
}

- (void)documentUpdated:(NSNotification *)notification
{
    Document *doc = notification.object;
    [self updateDocuments: [NSArray arrayWithObject: doc] isDeleteDocuments:NO isDelta:YES];
}

- (void)documentsListDidRefreshed:(NSNotification *)notification
{
    [self updateSyncStatus];
}

- (void)documentsListWillRefreshed:(NSNotification *)notification
{
    [self updateSyncStatus];
}

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
        
        DataSource *ds = [DataSource sharedDataSource];
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

            NSInteger count = [ds countUnreadDocumentsForFolder: f];
            item.badgeValue = count>0?[NSString stringWithFormat:@"%d", count]:nil;
        }
    }
    
}
@end