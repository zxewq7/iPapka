    //
//  DocumentInfoViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentInfoViewController.h"
#import "DocumentManaged.h"
#import "Document.h"
#import "Resolution.h"

static NSString *ParentResolutionCell = @"ParentResolutionCell";
static NSString *LinkCell = @"LinkCell";
static NSString *ResolutionCell = @"ResolutionCell";

@implementation DocumentInfoViewController

#pragma mark -
#pragma mark Properties
@synthesize document;


-(void) setDocument:(DocumentManaged *) aDocument
{
    if (document == aDocument)
        return;
    [document release];
    document = [aDocument retain];
    documentTitle.text = document.title;
    
    Document *doc = document.document;
    if (doc != unmanagedDocument) 
    {
        [unmanagedDocument release];
        unmanagedDocument = [doc retain];
    }

    [sections release];
    sections = [[NSMutableArray alloc] init];
    
    
    isResolution = [unmanagedDocument isMemberOfClass:[Resolution class]];
    hasParentResolution = isResolution && ((Resolution *)unmanagedDocument).parentResolution != nil;
    
    if (hasParentResolution) 
        [sections addObject:[NSMutableArray arrayWithObject:ParentResolutionCell]];

    NSUInteger linksCount = [unmanagedDocument.links count];
    if (linksCount)
    {
        NSMutableArray *linksArray = [NSMutableArray arrayWithCapacity:linksCount];
        for (NSUInteger i = 0; i<linksCount; i++) 
            [linksArray addObject:LinkCell];
        
        [sections addObject:linksArray];
    }
    
    if (isResolution)
        [sections addObject:[NSMutableArray arrayWithObject:ResolutionCell]];
    [tableView reloadData];
}

- (void)viewDidLoad
{
#define TOP_OFFSET 0
        //#define LEFT_OFFSET -30
        //#define RIGHT_OFFSET 40
#define LEFT_OFFSET 0
#define RIGHT_OFFSET 65

    [super viewDidLoad];
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocumentViewBackground.png"]];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];
    CGRect viewRect = self.view.bounds;
    CGRect tableViewRect = CGRectMake(viewRect.origin.x+LEFT_OFFSET, viewRect.origin.y + TOP_OFFSET, viewRect.size.width-LEFT_OFFSET-RIGHT_OFFSET, viewRect.size.height - TOP_OFFSET);
    tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
        //clear table background
        //http://useyourloaf.com/blog/2010/7/21/ipad-table-backgroundview.html
    tableView.backgroundView = nil;
    
        //create table header
        //http://cocoawithlove.com/2009/04/easy-custom-uitableview-drawing.html
    UIView *containerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    documentTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, tableViewRect.size.width, 40)];
    documentTitle.text = document.title;
    documentTitle.textColor = [UIColor whiteColor];
    documentTitle.textAlignment = UITextAlignmentCenter;
    documentTitle.font = [UIFont boldSystemFontOfSize:24];
    documentTitle.backgroundColor = [UIColor clearColor];
    [containerView addSubview:documentTitle];
    tableView.tableHeaderView = containerView;
    [containerView release];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
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
    [tableView release];
    tableView = nil;
    [documentTitle release];
    documentTitle = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return [sections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[sections objectAtIndex:section] count];
}

    // to determine which UITableViewCell to be used on a given row.
    //
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    UITableViewCell *cell = nil;
    
    if (cellIdentifier == ParentResolutionCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ParentResolutionCell];
        if (cell == nil)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ParentResolutionCell] autorelease];
        
        Resolution *parentResolution = ((Resolution *)unmanagedDocument).parentResolution;
        cell.textLabel.text = parentResolution.title;
        cell.detailTextLabel.text = [parentResolution.performers componentsJoinedByString: @", "];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (cellIdentifier == LinkCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:LinkCell];
        if (cell == nil)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ParentResolutionCell] autorelease];
        
        NSUInteger linkIndex = indexPath.row;
        Document *link = [unmanagedDocument.links objectAtIndex:linkIndex];
        cell.textLabel.text = link.title;
        cell.imageView.image = [UIImage imageNamed:@"LinkedDocumentIcon.png"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (cellIdentifier == ResolutionCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionCell];
        if (cell == nil)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResolutionCell] autorelease];

        Resolution *resolution = (Resolution *)unmanagedDocument;
        cell.textLabel.text = resolution.title;
        cell.detailTextLabel.text = [resolution.performers componentsJoinedByString: @", "];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	return cell;
}

- (void)dealloc {
    self.document = nil;
    [tableView release];
    [documentTitle release];
    [super dealloc];
}
@end
