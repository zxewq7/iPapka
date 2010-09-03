//
//  AttachmentPickerController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 03.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttachmentPickerController.h"
#import "Document.h"
#import "Attachment.h"

@implementation AttachmentPickerController
@synthesize document, target, selector, attachment;

#pragma mark -
#pragma mark Initialization

- (void) loadView
{
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.view = tableView;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    self.contentSizeForViewInPopover = CGSizeMake(self.view.frame.size.width, [document.attachments count]*43);
    [tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [document.attachments count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AttachmentCell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    Attachment *a = [document.attachments objectAtIndex:indexPath.row];
    cell.textLabel.text = a.title;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.attachment = [document.attachments objectAtIndex:indexPath.row];
    if( [target respondsToSelector:selector] )
        [target performSelector:selector withObject:self];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [tableView release];
    tableView = nil;
}


- (void)dealloc {
    [tableView release];
    [document release];
    [attachment release];
    [target release];
    [super dealloc];
}


@end

