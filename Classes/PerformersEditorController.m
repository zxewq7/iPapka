//
//  ArrayEditorController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 03.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PerformersEditorController.h"
#import "DocumentResolution.h"
#import "Person.h"

@implementation PerformersEditorController
@synthesize document, target, action;

-(void) setDocument:(DocumentResolution *)aDocument
{
    if (document != aDocument)
    {
        [document release];
        document = [aDocument retain];
    }
    
    
    self.contentSizeForViewInPopover = CGSizeMake(300, self.tableView.rowHeight * [document.performersOrdered count]);

    [self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];

    self.tableView.editing = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [document.performers count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PersonCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.showsReorderControl = YES;
    }
    
    Person *person = [document.performersOrdered objectAtIndex:indexPath.row];
    
    cell.textLabel.text = person.fullName;
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        [document.performersOrdered removeObjectAtIndex:indexPath.row];
        [self.target performSelector:self.action withObject:self];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
    NSMutableArray *array = document.performersOrdered;
    NSUInteger count = [array count];
    
    id object = [array objectAtIndex:fromIndexPath.row];
    [array removeObjectAtIndex:fromIndexPath.row];
    count--;
    
    NSInteger newIndex = toIndexPath.row + (toIndexPath.row?(toIndexPath.row + (toIndexPath.row > fromIndexPath.row)?-1:1):0);
    
    if (newIndex < 0)
        newIndex = 0;
    else if (newIndex >= count)
        newIndex = count - 1;
    
    [array insertObject:object atIndex:newIndex];
    
    [self.target performSelector:self.action withObject:self];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
    self.document = nil;
    self.target = nil;
    self.action = nil;
    [super dealloc];
}


@end

