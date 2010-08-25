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
#import "SegmentedLabel.h"
#import "SegmentedTableCell.h"

static NSString *ParentResolutionCell = @"ParentResolutionCell";
static NSString *LinkCell = @"LinkCell";
static NSString *ResolutionCell = @"ResolutionCell";
static NSString *ResolutionAuthorCell = @"ResolutionAuthorCell";
static NSString *ResolutionDateCell = @"ResolutionDateCell";
static NSString *ResolutionPerformersCell = @"ResolutionPerformersCell";
static NSString *ResolutionDeadlineCell = @"ResolutionDeadlineCell";
static NSString *ResolutionManagedCell = @"ResolutionManagedCell";
static NSString *ResolutionTextCell = @"ResolutionTextCell";

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
        [sections addObject:[NSMutableArray arrayWithObjects:ResolutionCell, ResolutionAuthorCell, ResolutionDateCell, nil]];
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

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM yyyy"];
    
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
    [dateFormatter release];
    dateFormatter = nil;
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
        {
            cell = [[[SegmentedTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ParentResolutionCell] autorelease];
            SegmentedLabel *aLabel = [[SegmentedLabel alloc] initWithFrame:CGRectMake(0, 0, 580, 20)];
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            label1.backgroundColor = [UIColor clearColor];
            label1.textColor = [UIColor blackColor];
            label1.font = [UIFont boldSystemFontOfSize:16];
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            label2.textColor = [UIColor darkGrayColor];
            label2.font = [UIFont systemFontOfSize:14];
            label2.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
            label2.backgroundColor = [UIColor clearColor];
            
            aLabel.backgroundColor = [UIColor clearColor];
            aLabel.labels = [NSArray arrayWithObjects:label1, label2, nil];
            ((SegmentedTableCell *)cell).segmentedLabel = aLabel;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor  =[UIColor whiteColor];
        }
        
        Resolution *parentResolution = ((Resolution *)unmanagedDocument).parentResolution;
        
        cell.detailTextLabel.text=NSLocalizedString(@"Expand", "Expand");

        NSMutableString *detailString = [NSMutableString stringWithString: NSLocalizedString(@"Author", "Author")];
        [detailString appendString:@": "];
        [detailString appendString:parentResolution.author]; 
        NSDate *date = parentResolution.date;
        if (detailString && ![detailString isEqualToString:@""] && date != nil)
            [detailString appendString:@", "];
        
        if (date != nil)
            [detailString appendString:[dateFormatter stringFromDate:date]];
        ((SegmentedTableCell *)cell).segmentedLabel.texts = [NSArray arrayWithObjects:[NSLocalizedString(@"Parent project", "Resolution project") stringByAppendingString:@"  "], 
                                                                                    detailString, nil];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (cellIdentifier == LinkCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:LinkCell];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LinkCell] autorelease];
            cell.backgroundColor  =[UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSUInteger linkIndex = indexPath.row;
        Document *link = [unmanagedDocument.links objectAtIndex:linkIndex];
        cell.textLabel.text = link.title;
        cell.imageView.image = [UIImage imageNamed:@"LinkedDocumentIcon.png"];
    }
    else if (cellIdentifier == ResolutionCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionCell];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResolutionCell] autorelease];
            cell.backgroundColor  =[UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        cell.textLabel.text = NSLocalizedString(@"Resolution project", "Resolution project");
        
    }
    else if (cellIdentifier == ResolutionAuthorCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionAuthorCell];
        if (cell == nil)
        {
            cell = [[[SegmentedTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ResolutionAuthorCell] autorelease];
            SegmentedLabel *aLabel = [[SegmentedLabel alloc] initWithFrame:CGRectMake(0, 0, 580, 20)];
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            label1.backgroundColor = [UIColor clearColor];
            label1.textColor = [UIColor blackColor];
            label1.font = [UIFont boldSystemFontOfSize:16];
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            label2.backgroundColor = [UIColor clearColor];
            label2.textColor =[UIColor darkGrayColor];
            label2.font = [UIFont systemFontOfSize:16];
            
            aLabel.backgroundColor = [UIColor clearColor];
            aLabel.labels = [NSArray arrayWithObjects:label1, label2, nil];
            ((SegmentedTableCell *)cell).segmentedLabel = aLabel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor  =[UIColor whiteColor];
        }
        
        NSString *detailString = document.author;
        ((SegmentedTableCell *)cell).segmentedLabel.texts = [NSArray arrayWithObjects:[NSLocalizedString(@"Author", "Author") stringByAppendingString:@"  "], 
                                                             detailString, nil];
        
        
    }    
    else if (cellIdentifier == ResolutionDateCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionDateCell];
        if (cell == nil)
        {
            cell = [[[SegmentedTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ResolutionDateCell] autorelease];
            SegmentedLabel *aLabel = [[SegmentedLabel alloc] initWithFrame:CGRectMake(0, 0, 580, 20)];
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            label1.backgroundColor = [UIColor clearColor];
            label1.textColor = [UIColor blackColor];
            label1.font = [UIFont boldSystemFontOfSize:16];
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            label2.backgroundColor = [UIColor clearColor];
            label2.textColor =[UIColor darkGrayColor];
            label2.font = [UIFont systemFontOfSize:16];
            label2.textAlignment = UITextAlignmentRight;
            
            aLabel.backgroundColor = [UIColor clearColor];
            aLabel.labels = [NSArray arrayWithObjects:label1, label2, nil];
            ((SegmentedTableCell *)cell).segmentedLabel = aLabel;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor  =[UIColor whiteColor];
        }
        
        NSString *detailString = [dateFormatter stringFromDate:document.dateModified];
        ((SegmentedTableCell *)cell).segmentedLabel.texts = [NSArray arrayWithObjects:[NSLocalizedString(@"Date of approval", "Date of approval") stringByAppendingString:@"  "],
                                                             detailString, nil];
    }
    
	return cell;
}

- (void)dealloc {
    self.document = nil;
    [tableView release];
    [documentTitle release];
    [dateFormatter release];
    [unmanagedDocument release];
    [sections release];
    [super dealloc];
}
@end