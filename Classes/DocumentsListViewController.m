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
#import "DocumentResolution.h"
#import "DocumentCellView.h"
#import "NSDateFormatter+Additions.h"
#import "AZZSegmentedLabel.h"

#define ROW_HEIGHT 94

static NSString* SyncingContext = @"SyncingContext";

@interface DocumentsListViewController(Private)
- (void) createToolbars;
- (void)updateSyncStatus;
- (void)updateContent;
- (void)updateBadges;
- (void)selectCurrentDocument;
@end


@implementation DocumentsListViewController

#pragma mark -
#pragma mark properties
@synthesize folder;
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
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;

    timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateStyle = NSDateFormatterNoStyle;
    timeFormatter.timeStyle = NSDateFormatterShortStyle;

    
    activityDateFormatter = [[NSDateFormatter alloc] init];
    activityDateFormatter.dateStyle = NSDateFormatterShortStyle;
    activityDateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    activityTimeFormatter = [[NSDateFormatter alloc] init];
    activityTimeFormatter.dateStyle = NSDateFormatterNoStyle;
    activityTimeFormatter.timeStyle = NSDateFormatterShortStyle;
    
    [self createToolbars];
    
    [[DataSource sharedDataSource] addObserver:self
                                    forKeyPath:@"isSyncing"
                                       options:0
                                       context:&SyncingContext];
    [self updateSyncStatus];
    [self updateContent];
}

/*
 http://stackoverflow.com/questions/2339721/hiding-a-uinavigationcontrollers-uitoolbar-during-viewwilldisappear
 only way to avlid back strips around uitableview
 */
- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO];
    
    [self selectCurrentDocument];
    
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

    return [dateFormatter stringForDateFromNow:doc.registrationDateStripped];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DocumentCellIdentifier";
    
        // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        DocumentCellView *contentView = [[DocumentCellView alloc] initWithFrame:CGRectMake(0, 0, 540, aTableView.rowHeight)];

        contentView.textLabel.font = [UIFont boldSystemFontOfSize:20.f];
        contentView.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        contentView.detailTextLabel1.font = [UIFont systemFontOfSize:14.f];
        contentView.detailTextLabel1.highlightedTextColor = [UIColor whiteColor];

        contentView.detailTextLabel2.font = [UIFont systemFontOfSize:14.f];
        contentView.detailTextLabel2.highlightedTextColor = [UIColor whiteColor];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
        label1.textColor = [UIColor colorWithRed:0.804 green:0.024 blue:0.024 alpha:1.0];
        label1.highlightedTextColor = [UIColor whiteColor];
        label1.font = [UIFont boldSystemFontOfSize:12.f];
        label1.backgroundColor = [UIColor clearColor];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
        label2.textColor = [UIColor colorWithRed:0.718 green:0.635 blue:0.173 alpha:1.0];
        label2.highlightedTextColor = [UIColor whiteColor];
        label2.font = [UIFont boldSystemFontOfSize:12.f];
        label2.backgroundColor = [UIColor clearColor];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectZero];
        label3.textColor = [UIColor colorWithRed:0.118 green:0.506 blue:0.051 alpha:1.0];
        label3.highlightedTextColor = [UIColor whiteColor];
        label3.font = [UIFont boldSystemFontOfSize:12.f];
        label3.backgroundColor = [UIColor clearColor];

        UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectZero];
        label4.textColor = [UIColor blackColor];
        label4.highlightedTextColor = [UIColor whiteColor];
        label4.font = [UIFont systemFontOfSize:12.f];
        label4.backgroundColor = [UIColor clearColor];
        
        contentView.detailTextLabel3.labels = [NSArray arrayWithObjects:label1, label2, label3, label4, nil];
        
        [label1 release];
        [label2 release];
        [label3 release];
        [label4 release];
        
        [cell.contentView addSubview:contentView];

        [contentView release];

	}
    DocumentCellView *contentView = [cell.contentView.subviews objectAtIndex:0];
    
        // Set appropriate labels for the cells.
    Document *doc = [fetchedResultsController objectAtIndexPath:indexPath];

    contentView.textLabel.text = doc.title;
    
    NSString *details1;
    
    if ([doc isKindOfClass:[DocumentResolution class]])
    {
        if ([doc.correspondents count])
            details1 = [NSString stringWithFormat:@"%@ %@ %@, %@", doc.registrationNumber, NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: doc.registrationDate], [doc.correspondents componentsJoinedByString:@", "]];
        else
            details1 = [NSString stringWithFormat:@"%@ %@ %@", doc.registrationNumber, NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: doc.registrationDate]];
    }
    else if ([doc.correspondents count])
        details1 = [NSString stringWithFormat:@"%@ %@, %@", NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: doc.registrationDate], [doc.correspondents componentsJoinedByString:@", "]];
    else
        details1 = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: doc.registrationDate]];
    
    contentView.detailTextLabel1.text = details1;
    
    if (doc.statusValue == DocumentStatusNew)
    {
        contentView.detailTextLabel2.text = NSLocalizedString(@"Unmodified", @"DocumentList->Unmodified");
        contentView.detailTextLabel2.textColor = [UIColor darkGrayColor];
    }
    else
    {
        contentView.detailTextLabel2.text = [NSString stringWithFormat:@"%@ %@ %@ %@", NSLocalizedString(@"Modified", @"DocumentList->Modified"), [dateFormatter stringFromDate: doc.dateModified], NSLocalizedString(@"at", @"documentList-> modified at time"), [timeFormatter stringFromDate: doc.dateModified]];
        contentView.detailTextLabel2.textColor = [UIColor colorWithRed:0.137 green:0.467 blue:0.929 alpha:1.0];
    }

    NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:4];
    BOOL isPriority = (doc.priorityValue > 0);
    BOOL isStatus = NO;
    
    if (isPriority)
        [labels addObject: [NSLocalizedString(@"Important", @"Important") uppercaseString]];
    else
        [labels addObject: @""];
    
    switch (doc.statusValue)
    {
        case DocumentStatusAccepted:
            [labels addObject: @""];

            if (isPriority)
                [labels addObject: [@" " stringByAppendingString:[NSLocalizedString(@"Accepted", @"Accepted") uppercaseString]]];
            else
                [labels addObject: [NSLocalizedString(@"Accepted", @"Accepted") uppercaseString]];
            
            
            isStatus = YES;
            break;
        case DocumentStatusDeclined:
            if (isPriority)
                [labels addObject: [@" " stringByAppendingString:[NSLocalizedString(@"Declined", @"Declined") uppercaseString]]];
            else
                [labels addObject: [NSLocalizedString(@"Declined", @"Declined") uppercaseString]];
            
            [labels addObject: @""];
            
            isStatus = YES;
            break;
        default:
            [labels addObject: @""];
            [labels addObject: @""];
            break;
    }
    
    if ([doc.attachments count] > 1 || [doc.links count])
    {
        NSString *attachmentsString;
        NSString *attachmentsName;
        
        switch ([doc.attachments count])
        {
            case 1:
                attachmentsName = NSLocalizedString(@"attachment", @"attachment");
                break;
            case 2:
            case 3:
            case 4:
                attachmentsName = NSLocalizedString(@"attachment24", @"number of attachments from 2 to 4 in genitivus");
                break;
            default:
                attachmentsName = NSLocalizedString(@"attachments_genitivus", @"attachments in genitivus");
                break;
        }
        
        if ([doc.links count])
        {
            NSString *linksName;
            
            switch ([doc.links count])
            {
                case 1:
                    linksName = NSLocalizedString(@"linked document", @"linked document");
                    break;
                case 2:
                case 3:
                case 4:
                    linksName = NSLocalizedString(@"linked document24", @"number of linked documents from 2 to 4 in genitivus");
                    break;
                default:
                    linksName = NSLocalizedString(@"linked documents_genitivus", @"linked documents");
                    break;
            }

            attachmentsString = [NSString stringWithFormat:@"%@ %d %@ %@ %d %@",(isStatus || isPriority ? @", ":@""), [doc.attachments count], attachmentsName, NSLocalizedString(@"and", "and"), [doc.links count], linksName];
        }
        else
            attachmentsString = [NSString stringWithFormat:@"%@ %d %@",(isStatus || isPriority ? @", ":@""), [doc.attachments count], attachmentsName];
        
        [labels addObject: attachmentsString];
        
        contentView.attachmentImageView.image = [UIImage imageNamed:@"Attachment.png"];
    }
    else
    {
        [labels addObject: @""];
        contentView.attachmentImageView.image = nil;
    }
    
    contentView.detailTextLabel3.texts = labels;
    
    [labels release];
    
    contentView.imageView.image = doc.isReadValue?[UIImage imageNamed:@"ReadMark.png"]:[UIImage imageNamed:@"UnreadMark.png"];
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
    [self selectCurrentDocument];

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
    [self selectCurrentDocument];
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
    [[DataSource sharedDataSource] sync:YES];
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
    [dateFormatter release]; dateFormatter = nil;
    [titleLabel release]; titleLabel = nil;
    [detailsLabel release]; detailsLabel = nil;
    [activityDateFormatter release]; activityDateFormatter = nil;
    [activityTimeFormatter release]; activityDateFormatter = nil;
    [filtersBar release]; filtersBar = nil;
    [timeFormatter release]; timeFormatter = nil;

    
    [[DataSource sharedDataSource] removeObserver:self
                                       forKeyPath:@"isSyncing"];
    
}

- (void)dealloc 
{
    [dateFormatter release]; dateFormatter = nil;
    self.folder = nil;
    [titleLabel release]; titleLabel = nil;
    [detailsLabel release]; detailsLabel = nil;
    [activityDateFormatter release]; activityDateFormatter = nil;
    [activityTimeFormatter release]; activityDateFormatter = nil;
    self.delegate = nil;
    self.document =  nil;
    [filtersBar release]; filtersBar = nil;
    [fetchedResultsController release]; fetchedResultsController = nil;

    [[DataSource sharedDataSource] removeObserver:self
                                       forKeyPath:@"isSyncing"];
    
    [timeFormatter release]; timeFormatter = nil;
    [super dealloc];
}
@end

@implementation DocumentsListViewController(Private)
- (void) createToolbars;
{
    //create bottom toolbar
    //http://stackoverflow.com/questions/1072604/whats-the-right-way-to-add-a-toolbar-to-a-uitableview
    
    UIButton *cancelButton = [UIButton buttonWithBackgroundAndTitle:NSLocalizedString(@"Close", "Close")
                                                          titleFont:[UIFont boldSystemFontOfSize:12]
                                                             target:self
                                                           selector:@selector(dismiss:)
                                                              frame:CGRectMake(0, 0, 20, 30)
                                                      addLabelWidth:YES
                                                              image:[UIImage imageNamed:@"ButtonSquare.png"]
                                                       imagePressed:[UIImage imageNamed:@"ButtonSquareSelected.png"]
                                                       leftCapWidth:10.0f
                                                      darkTextColor:NO];
    [cancelButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    [cancelBarButton release];
    
    
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
    
    self.navigationItem.rightBarButtonItem = refreshBarButton;
    [refreshBarButton release];

    
    //http://www.developers-life.com/customizing-uinavigationbar.html
    UIView *containerView =[[UIView alloc] initWithFrame:CGRectMake(0, 170, 300, 44)];
    
    CGSize containerSize = containerView.frame.size;
    
    CGRect titleFrame = CGRectMake(0, 5.0, containerSize.width, 20);
    titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    
    CGRect detailsFrame = CGRectMake(0, 25.0, containerSize.width, 20);
    detailsLabel = [[UILabel alloc] initWithFrame: detailsFrame];
    detailsLabel.backgroundColor = [UIColor clearColor];
    detailsLabel.font = [UIFont boldSystemFontOfSize:12.0];
    detailsLabel.textAlignment = UITextAlignmentCenter;
    detailsLabel.textColor = [UIColor whiteColor];
    detailsLabel.shadowColor = [UIColor blackColor];
    detailsLabel.shadowOffset = CGSizeMake(0.0, -1.0);

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
            detailsLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Synchronized", "Synchronized"), [activityTimeFormatter stringFromDate:lastSynced], [activityDateFormatter stringFromDate:lastSynced]];
        
        [self updateBadges];
    }
    
}

- (void)updateContent
{

    //deselect selected row
    if (folder)
    {
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
            
            if ([document isKindOfClass: f.entityClass] && [f.predicate evaluateWithObject: document])
            {
                filterIndex = i;
            }

        }
        filtersBar.items = toolbarItems;

        UITabBarItem *item = [filtersBar.items objectAtIndex: filterIndex];
        
        filtersBar.selectedItem = item;
        
        [self tabBar:filtersBar didSelectItem: item];
    }
    else
        filterIndex = NSNotFound;
    
    titleLabel.text = folder.localizedName;
    
    [self updateBadges];
}

- (void)updateBadges
{
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

- (void)selectCurrentDocument
{
    NSIndexPath *index = [fetchedResultsController indexPathForObject:self.document];
    NSIndexPath *prevSelected = self.tableView.indexPathForSelectedRow;
    if (index && !prevSelected || (prevSelected.row != index.row && prevSelected.section != index.section))
    {
        
        if (prevSelected)
            [self.tableView deselectRowAtIndexPath:index animated:NO];
        
        [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}
@end