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
#import "Folder.h";

#define ROW_HEIGHT 94

@interface RootViewController(Private)
- (void)documentsAdded:(NSNotification *)notification;
- (void)documentsRemoved:(NSNotification *)notification;
- (void)documentsUpdated:(NSNotification *)notification;
- (void)updateDocuments:(NSArray *) documents isDeleteDocuments:(BOOL)isDeleteDocuments;
@end


@implementation RootViewController

#pragma mark -
#pragma mark properties
@synthesize popoverController, 
            rootPopoverButtonItem, 
            sections, 
            sectionsOrdered, 
            sectionsOrderedLabels, 
            dateFormatter, 
            sortDescriptors, 
            folder,
            splitViewController;

- (void) setFolder:(Folder *)aFolder
{
    if (folder == aFolder)
        return;
    [folder release];
    folder = [aFolder retain];
    self.title = folder.localizedName;
    [self updateDocuments:[[[LNDataSource sharedLNDataSource] documents] allValues] isDeleteDocuments:NO];
    self.rootPopoverButtonItem.title = folder.localizedName;
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
                                  
    [self updateDocuments: [[LNDataSource sharedLNDataSource].documents allValues] isDeleteDocuments:NO];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsAdded:)
                                                 name:@"DocumentsAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsRemoved:)
                                                 name:@"DocumentsRemoved" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentsUpdated:)
                                                 name:@"DocumentsUpdated" object:nil];
}

-(void) viewDidUnload {
	[super viewDidUnload];
	
	self.rootPopoverButtonItem = nil;
}

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {
    
        // Keep references to the popover controller and the popover button, and tell the detail view controller to show the button.
    barButtonItem.title = folder.localizedName;
    self.popoverController = pc;
    self.rootPopoverButtonItem = barButtonItem;
    DocumentViewController *detailViewController = [svc.viewControllers objectAtIndex:1];
    [detailViewController showRootPopoverButtonItem:rootPopoverButtonItem];
}


- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
        // Nil out references to the popover controller and the popover button, and tell the detail view controller to hide the button.
    DocumentViewController *detailViewController = [svc.viewControllers objectAtIndex:1];
    [detailViewController invalidateRootPopoverButtonItem:rootPopoverButtonItem];
    barButtonItem.title = folder.localizedName;
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
    DocumentViewController *detailViewController = [splitViewController.viewControllers objectAtIndex:1];
    
    NSArray *documentSection = [self.sections objectForKey:[self.sectionsOrdered objectAtIndex:indexPath.section]];
    Document *document = [documentSection objectAtIndex:indexPath.row];

    detailViewController.document = document;

        // Dismiss the popover if it's present.
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }
    
        // Configure the new view controller's popover button (after the view has been displayed and its toolbar/navigation bar has been created).
    if (rootPopoverButtonItem != nil) {
        [detailViewController showRootPopoverButtonItem:self.rootPopoverButtonItem];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    self.popoverController = nil;
    self.rootPopoverButtonItem = nil;
    self.splitViewController = nil;
    
    self.sections = nil;
    self.sectionsOrdered = nil;
    self.sectionsOrderedLabels = nil;
    self.dateFormatter = nil;
    self.sortDescriptors = nil;
    self.folder = nil;
    [super dealloc];
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
        NSDate *documentDate = document.date;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:documentDate];
        NSDate *documentSection = [calendar dateFromComponents:comps];
        NSUInteger sectionIndex = [self.sectionsOrdered indexOfObject:documentSection];
        
        if (isDeleteDocuments || ![filter evaluateWithObject:document])
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
                    if ([documentSection earlierDate:section]) 
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
@end
