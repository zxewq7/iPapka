//
//  PersonPickerViewController.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 18.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
// based on http://stackoverflow.com/questions/1112521/nsfetchedresultscontroller-with-sections-created-by-first-letter-of-a-string
//

#import "PersonPickerViewController.h"
#import "Person.h"
#import "DataSource.h"

@interface PersonPickerViewController(Private)
-(UITableView *) tableView;
@end

@implementation PersonPickerViewController
@synthesize persons, action, target;

-(void) setPersons:(NSMutableArray *)ps
{
    if (ps != persons)
    {
        [persons release];
        persons = [ps retain];
    }
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    fetchedResultsController = [[DataSource sharedDataSource] persons];
    [fetchedResultsController retain];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    if (![fetchedResultsController performFetch:&error]) 
        NSAssert1(NO, @"Unhandled error executing fetch persons: %@", [error localizedDescription]);
    
    CGSize viewSize = self.view.bounds.size;
    
    filterSwitcher = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:NSLocalizedString(@"Add", "Add"), NSLocalizedString(@"Reorder", "Reorder"), nil]];
    filterSwitcher.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [filterSwitcher sizeToFit];
    
    [filterSwitcher addTarget:self action:@selector(switchFilter:) forControlEvents:UIControlEventValueChanged];
    
    filterSwitcher.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    CGRect filterSwitcherFrame = filterSwitcher.frame;
    filterSwitcherFrame.origin.x = 0;
    filterSwitcherFrame.origin.y = 0;
    filterSwitcherFrame.size.width = viewSize.width;
    
    filterSwitcher.frame = filterSwitcherFrame;
    
    filterSwitcher.selectedSegmentIndex = 0;
    
    [self.view addSubview: filterSwitcher];
    
    CGRect tableViewFrame = CGRectMake(0, filterSwitcherFrame.size.height, viewSize.width, viewSize.height - filterSwitcherFrame.size.height);
    
    tableView = [[UITableView alloc] initWithFrame:tableViewFrame style: UITableViewStylePlain];
    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview: tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{
    switch (filterSwitcher.selectedSegmentIndex)
    {
        case 0:
            return [[fetchedResultsController sections] count];
        default:
            return 1;
    }
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
    id <NSFetchedResultsSectionInfo> sectionInfo;
    
    switch (filterSwitcher.selectedSegmentIndex)
    {
        case 0:
            sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        case 1:
            return [self.persons count];
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    // Section title is the region name
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];

    if (filterSwitcher.selectedSegmentIndex == 0)
        return [sectionInfo name];
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PersonCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    }
    
    Person *p = nil;;
    
    switch (filterSwitcher.selectedSegmentIndex)
    {
        case 0:
            p = [fetchedResultsController objectAtIndexPath:indexPath];
            cell.showsReorderControl = NO;
            break;
        case 1:
            p = [self.persons objectAtIndex:indexPath.row];
            cell.showsReorderControl = YES;
            break;
    }

    cell.textLabel.text = p.fullName;
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    if (filterSwitcher.selectedSegmentIndex)
        return nil;
    
    NSArray *sections = [fetchedResultsController sections];
    NSMutableArray *index = [NSMutableArray arrayWithCapacity:[sections count]];
    
    //for some reason [fetchedResultsController sectionIndexTitles] returns wrong results
    for (id <NSFetchedResultsSectionInfo> sectionInfo in sections)
        [index addObject:[sectionInfo name]];

    return index;
}
#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    Person *person = nil;
    
    switch (filterSwitcher.selectedSegmentIndex)
    {
        case 0:
            person = [fetchedResultsController objectAtIndexPath:indexPath];
            [self.persons addObject:person];
            [target performSelector:action withObject:self];
            break;
    }
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        [self.persons removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [self.target performSelector:self.action withObject:self];
    }   
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
    NSMutableArray *array = self.persons;
    
    id object = [array objectAtIndex:fromIndexPath.row];
    [array removeObjectAtIndex:fromIndexPath.row];
    [array insertObject:object atIndex:toIndexPath.row];
    
    [self.target performSelector:self.action withObject:self];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    if (filterSwitcher.selectedSegmentIndex)
        return;

    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (filterSwitcher.selectedSegmentIndex)
        return;

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    if (filterSwitcher.selectedSegmentIndex)
        return;
    
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
    if (filterSwitcher.selectedSegmentIndex)
        return;
    
    [self.tableView endUpdates];
}
#pragma mark
#pragma actions
-(void)switchFilter:(id) sender
{
    self.tableView.editing = (filterSwitcher.selectedSegmentIndex == 1);
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Memory management
- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    [fetchedResultsController release]; fetchedResultsController = nil;
    [tableView release]; tableView = nil;
    [filterSwitcher release]; filterSwitcher = nil;
}


- (void)dealloc 
{
    [fetchedResultsController release]; fetchedResultsController = nil;
    
    self.persons = nil;
    
    self.target = nil;
    
    self.action = nil;
    
    [tableView release]; tableView = nil;
    
    [filterSwitcher release]; filterSwitcher = nil;

    [super dealloc];
}

#pragma Private
-(UITableView *) tableView
{
    return tableView;
}
@end

