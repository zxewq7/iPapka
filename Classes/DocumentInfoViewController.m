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
static NSString *ResolutionAuthorCell = @"ResolutionAuthorCell";
static NSString *ResolutionDateCell = @"ResolutionDateCell";
static NSString *ResolutionPerformersCell = @"ResolutionPerformersCell";
static NSString *ResolutionDeadlineCell = @"ResolutionDeadlineCell";
static NSString *ResolutionManagedCell = @"ResolutionManagedCell";
static NSString *ResolutionTextCell = @"ResolutionTextCell";

#define kPerformersFieldTag 1
#define kDetailLabelTag 2
#define TEXT_FIELD_HEIGHT  25
#define DETAIL_LABEL_HEIGHT  20

@interface  DocumentInfoViewController(Private)
-(UITableViewCell *) createDetailsCell:(NSString *) label identifier:(NSString *) identifier;
@end


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
        [sections addObject:[NSMutableArray arrayWithObjects:ResolutionCell, 
                                                             ResolutionAuthorCell, 
                                                             ResolutionDateCell,
                                                             ResolutionPerformersCell, nil]];
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
            cell = [self createDetailsCell:NSLocalizedString(@"Parent project", "Resolution project") identifier:ParentResolutionCell];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        Resolution *parentResolution = ((Resolution *)unmanagedDocument).parentResolution;

        NSMutableString *detailString = [NSMutableString stringWithString: NSLocalizedString(@"Author", "Author")];
        [detailString appendString:@": "];
        [detailString appendString:parentResolution.author]; 
        NSDate *date = parentResolution.date;
        if (detailString && ![detailString isEqualToString:@""] && date != nil)
            [detailString appendString:@", "];
        
        if (date != nil)
            [detailString appendString:[dateFormatter stringFromDate:date]];
        
        
        UILabel *field = (UILabel *)[cell.contentView viewWithTag:kDetailLabelTag];
        if (field) 
        {
            field.text = detailString;
            [field sizeToFit];
        }
        
        cell.detailTextLabel.text=NSLocalizedString(@"Expand", "Expand");

    }
    else if (cellIdentifier == LinkCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:LinkCell];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:LinkCell] autorelease];
            cell.backgroundColor  =[UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSUInteger linkIndex = indexPath.row;
        Document *link = [unmanagedDocument.links objectAtIndex:linkIndex];
        cell.textLabel.text = link.title;
        cell.detailTextLabel.text = NSLocalizedString(@"Document", "Document");
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
            cell.textLabel.text = NSLocalizedString(@"Resolution project", "Resolution project");
        }
    }
    else if (cellIdentifier == ResolutionAuthorCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionAuthorCell];
        if (cell == nil)
            cell = [self createDetailsCell:NSLocalizedString(@"Author", "Author") identifier:ResolutionAuthorCell];
        
        UILabel *field = (UILabel *)[cell.contentView viewWithTag:kDetailLabelTag];
        if (field) 
        {
            field.text = document.author;
            [field sizeToFit];
        }
    }    
    else if (cellIdentifier == ResolutionDateCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionDateCell];
        if (cell == nil)
            cell = [self createDetailsCell:NSLocalizedString(@"Date of approval", "Date of approval") identifier:ResolutionDateCell];

        UILabel *field = (UILabel *)[cell.contentView viewWithTag:kDetailLabelTag];
        if (field) 
        {
            field.text = [dateFormatter stringFromDate:document.dateModified];
            [field sizeToFit];
        }
    }
    else if (cellIdentifier == ResolutionPerformersCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionPerformersCell];
		if (cell == nil)
		{
                // a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResolutionPerformersCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor  =[UIColor whiteColor];
            
                //create performers field
            NSString *label = NSLocalizedString(@"Performers", "Performers");
            CGSize labelSize = [label sizeWithFont:[UIFont boldSystemFontOfSize: 17]];
            cell.textLabel.text = label;
            
            CGRect labelFrame = cell.textLabel.frame;
            CGRect cellFrame = cell.frame;
            
            CGRect performersFieldFrame = CGRectMake(labelFrame.origin.y+labelSize.width+20, (cellFrame.size.height-TEXT_FIELD_HEIGHT)/2, 450, TEXT_FIELD_HEIGHT);

            UITextField *performersField = [[UITextField alloc] initWithFrame:performersFieldFrame];
            
            performersField.borderStyle = UITextBorderStyleNone;
            performersField.textColor = [UIColor blackColor];
                //            performersField.font = [UIFont systemFontOfSize:17.0];
            performersField.backgroundColor = [UIColor whiteColor];
            performersField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
            performersField.tag = kPerformersFieldTag;
            
            performersField.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
            performersField.returnKeyType = UIReturnKeyDone;
            
            performersField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
            
            performersField.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
            
                // Add an accessibility label that describes what the text field is for.
            [performersField setAccessibilityLabel:NSLocalizedString(@"NormalTextField", @"")];
            [cell.contentView addSubview:performersField];
            
            UIButton* addPerformerButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [addPerformerButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
            CGSize addPerformerButtonSize = addPerformerButton.frame.size;
            CGRect addPerformerButtonFrame = CGRectMake(performersFieldFrame.origin.x+performersFieldFrame.size.width+20, (cellFrame.size.height-addPerformerButtonSize.height)/2, addPerformerButtonSize.height, addPerformerButtonSize.width);
            addPerformerButton.frame = addPerformerButtonFrame;
            [cell.contentView addSubview:addPerformerButton];
		}
        
        UITextField *field = (UITextField *)[cell.contentView viewWithTag:kPerformersFieldTag];
        if (field) 
            field.text = [((Resolution *)unmanagedDocument).performers componentsJoinedByString: @", "];
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

@implementation  DocumentInfoViewController(Private)
-(UITableViewCell *) createDetailsCell:(NSString *) label identifier:(NSString *) identifier
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    
    CGSize labelSize = [label sizeWithFont:[UIFont boldSystemFontOfSize: 17]];
    cell.textLabel.text = label;
    CGRect detailFrame = CGRectMake(labelSize.width+20, (cell.frame.size.height-DETAIL_LABEL_HEIGHT)/2, 10, DETAIL_LABEL_HEIGHT);
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:detailFrame];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor =[UIColor darkGrayColor];
    detailLabel.font = [UIFont systemFontOfSize:16];
    detailLabel.textAlignment = UITextAlignmentRight;
    detailLabel.tag = kDetailLabelTag;
    [cell.contentView addSubview: detailLabel];
        //[detailLabel release];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor  =[UIColor whiteColor];
    return cell;
}
@end
