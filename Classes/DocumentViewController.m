    //
//  DocumentViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentViewController.h"
#import "DocumentManaged.h"
#import "DataSource.h"

@implementation DocumentViewController

#pragma mark -
#pragma mark Properties
@synthesize toolbar, document, documentTitle, tableView;


-(void) setDocument:(DocumentManaged *) aDocument
{
    if (document == aDocument)
        return;
    [document release];
    document = [aDocument retain];
    
    documentTitle.title = document.title;
    if (![document.isRead boolValue])
        document.isRead = [NSNumber numberWithBool:YES];
    [[DataSource sharedDataSource] commit];
}

 - (void)viewDidLoad
{
    [super viewDidLoad];
    if (document == nil) 
    {
        documentTitle.title = nil;
    }
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocumentViewBackground.png"]];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];
    
        //clear table background
        //http://useyourloaf.com/blog/2010/7/21/ipad-table-backgroundview.html
    tableView.backgroundView = nil;
}

    // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        // Return YES for supported orientations
    return YES;
}

- (void)didReceiveMemoryWarning {
        // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
        // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
        // Release any retained subviews of the main view.
        // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Managing the popover

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
        // Add the popover button to the toolbar.
    NSMutableArray *itemsArray = [toolbar.items mutableCopy];
    [itemsArray insertObject:barButtonItem atIndex:0];
    [toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}


- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem {
    
        // Remove the popover button from the toolbar.
    NSMutableArray *itemsArray = [toolbar.items mutableCopy];
    [itemsArray removeObject:barButtonItem];
    [toolbar setItems:itemsArray animated:NO];
    [itemsArray release];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return 10;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    if (section == 1)
        return 3;
    if (section == 2)
        return 1;
    return 10;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    if (section<3)
        return nil;
    
	return @"Document name long long";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section>2)
        return 20;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[[UIView alloc] 
                           initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)]
                          autorelease];
  	customView.backgroundColor = [UIColor clearColor];
    
    
    UILabel * headerLabel = [[[UILabel alloc]
                              initWithFrame:CGRectZero] autorelease];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.frame = CGRectMake(0,-11, 320.0, 44.0);
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.text = [NSString stringWithString:@"Your Text"];
    
  	[customView addSubview:headerLabel];
    
    return customView;
}
    // to determine which UITableViewCell to be used on a given row.
    //
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellIdentifier = @"CaptionCellIdentifier";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
    if (indexPath.section == 0)
        cell.textLabel.text = @"parent resolution";
    else if (indexPath.section == 1)
        cell.textLabel.text = @"linked document";
    else if (indexPath.section == 2)
        cell.textLabel.text = @"Resolution itself";
    else
        cell.textLabel.text = @"page";
    
	return cell;
}

- (void)dealloc {
    self.toolbar = nil;
    self.document = nil;
    self.documentTitle = nil;
    self.tableView = nil;
    [super dealloc];
}
@end
