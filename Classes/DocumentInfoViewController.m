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
#define kDateButtonTag 3
#define kSwitchTag 4
#define kTextTag 5
#define TEXT_FIELD_HEIGHT  25
#define DETAIL_LABEL_HEIGHT  20
#define DATE_BUTTON_HEIGHT  25
#define SWITCH_HEIGHT  27
#define SWITCH_WIDTH  94
#define CELL_RIGHT_OFFSET  7.0f
#define CELL_LEFT_OFFSET  13.0f
#define CELL_HEIGHT 44
#define CELL_TOP_OFFSET 10.0f
#define CELL_BOTTOM_OFFSET 10.0f

@interface  DocumentInfoViewController(Private)
-(UITableViewCell *) createDetailsCell:(NSString *) label identifier:(NSString *) identifier;
- (UIButton *)buttonWithTitle:(NSString *)title
                       target:(id)target
                     selector:(SEL)selector
                        frame:(CGRect)frame
                        image:(UIImage *)image
                 imagePressed:(UIImage *)imagePressed
                darkTextColor:(BOOL)darkTextColor;
-(UILabel *) createLabelWithText:(NSString *) text;
-(void) createTableView:(CGFloat) leftOffset rightOffset:(CGFloat) rightOffset;
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
                                                             ResolutionPerformersCell,
                                                             ResolutionDeadlineCell,
                                                             ResolutionManagedCell,
                                                             ResolutionTextCell, nil]];
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM yyyy"];
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocumentViewBackground.png"]];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
        //recalc width
    CGFloat rightOffset = 51.0f;
    CGFloat leftOffset = -25.0f;
    cellWidth = 730.0f;
    switch (toInterfaceOrientation) 
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            rightOffset = -15.0f;
            leftOffset = -25.0f;
            cellWidth = 665.0f;
            break;
    }
    [self createTableView:leftOffset rightOffset:rightOffset];
    
    [tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cellIdentifier == ResolutionTextCell)
    {
        UILabel* text = [self createLabelWithText:((Resolution *)unmanagedDocument).text];
        CGFloat height = text.frame.size.height; 
        return height<CELL_HEIGHT?CELL_HEIGHT:(height+CELL_TOP_OFFSET+CELL_BOTTOM_OFFSET);
    }
    return CELL_HEIGHT;
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
            CGRect addPerformerButtonFrame = CGRectMake(cellWidth-CELL_RIGHT_OFFSET-addPerformerButtonSize.width, (cellFrame.size.height-addPerformerButtonSize.height)/2, addPerformerButtonSize.height, addPerformerButtonSize.width);
            addPerformerButton.frame = addPerformerButtonFrame;
            [cell.contentView addSubview:addPerformerButton];
		}
        
        UITextField *field = (UITextField *)[cell.contentView viewWithTag:kPerformersFieldTag];
        if (field) 
            field.text = [((Resolution *)unmanagedDocument).performers componentsJoinedByString: @", "];
    }
    else if (cellIdentifier == ResolutionDeadlineCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionDeadlineCell];
		if (cell == nil)
		{
                // a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResolutionDeadlineCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor  =[UIColor whiteColor];
            
                //create date button
            NSString *label = NSLocalizedString(@"Deadline", "Deadline");
            CGSize labelSize = [label sizeWithFont:[UIFont boldSystemFontOfSize: 17]];
            cell.textLabel.text = label;
            
            CGRect labelFrame = cell.textLabel.frame;
            CGRect cellFrame = cell.frame;
            
            CGRect dateButtonFrame = CGRectMake(labelFrame.origin.y+labelSize.width+20, (cellFrame.size.height-DATE_BUTTON_HEIGHT)/2, 10, DATE_BUTTON_HEIGHT);
            
            UIButton *dateButton = [self buttonWithTitle:@""
                                             target:self
                                           selector:nil
                                              frame:dateButtonFrame
                                              image:[UIImage imageNamed:@"ButtonDate.png"]
                                       imagePressed:nil
                                           darkTextColor:YES];
            dateButton.tag = kDateButtonTag;
            [cell.contentView addSubview:dateButton];
		}
        
        UIButton *button = (UIButton *)[cell.contentView viewWithTag:kDateButtonTag];
        if (button) 
        {
            NSString *label  = @"11 august 2010 11 august 2010";
            [button setTitle:label forState:UIControlStateNormal];
            CGSize labelSize = [label sizeWithFont:[UIFont boldSystemFontOfSize: 17]];
            CGRect oldButtonFrame = button.frame;
            CGRect newButtonFrame = CGRectMake(oldButtonFrame.origin.x, oldButtonFrame.origin.y,labelSize.width, DATE_BUTTON_HEIGHT);
            button.frame = newButtonFrame;
        }
    }
    else if (cellIdentifier == ResolutionManagedCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionManagedCell];
		if (cell == nil)
		{
                // a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResolutionManagedCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor  =[UIColor whiteColor];
            
                //create managed switch
            NSString *label = NSLocalizedString(@"Managed", "Managed");
            cell.textLabel.text = label;
            
            CGRect cellFrame = cell.frame;
            
            CGRect switchFrame = CGRectMake(cellWidth-CELL_RIGHT_OFFSET-SWITCH_WIDTH, (cellFrame.size.height-SWITCH_HEIGHT)/2, SWITCH_HEIGHT, SWITCH_WIDTH);
            
            UISwitch* switchButton = [[[UISwitch alloc] initWithFrame:switchFrame] autorelease];
            [switchButton addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
            switchButton.tag = kSwitchTag;
            [cell.contentView addSubview:switchButton];
		}
        
        UISwitch *button = (UISwitch *)[cell.contentView viewWithTag:kSwitchTag];
        if (button) 
            [button setOn: ((Resolution *)unmanagedDocument).managed animated:NO];
    }    
    else if (cellIdentifier == ResolutionTextCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ResolutionTextCell];
		if (cell == nil)
		{
                // a new cell needs to be created
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResolutionTextCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor  =[UIColor whiteColor];
                //create managed switch
            UILabel* text = [self createLabelWithText:@""];
            text.tag = kTextTag;
            text.numberOfLines=0;
            [cell.contentView addSubview:text];
		}
        
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:kTextTag];
        if (label)
        {
            label.text=((Resolution *)unmanagedDocument).text;
            CGRect labelFrame = label.frame;
            labelFrame.size.width = cellWidth-CELL_RIGHT_OFFSET-CELL_LEFT_OFFSET;
            label.frame = labelFrame;
            [label sizeToFit];
        }
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
    
    UILabel *detailLabel = [[[UILabel alloc] initWithFrame:detailFrame] autorelease];
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor =[UIColor darkGrayColor];
    detailLabel.font = [UIFont systemFontOfSize:16];
    detailLabel.textAlignment = UITextAlignmentRight;
    detailLabel.tag = kDetailLabelTag;
    [cell.contentView addSubview: detailLabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor  =[UIColor whiteColor];
    return cell;
}

- (UIButton *)buttonWithTitle:(NSString *)title
                          target:(id)target
                        selector:(SEL)selector
                           frame:(CGRect)frame
                           image:(UIImage *)image
                    imagePressed:(UIImage *)imagePressed
                   darkTextColor:(BOOL)darkTextColor
{	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
        // or you can do this:
        //		UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
        // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	
	return button;
}

-(UILabel *) createLabelWithText:(NSString *) text
{
    UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.numberOfLines=0;

    label.text=text;
    CGRect labelFrame = label.frame;
    labelFrame.origin.x = CELL_LEFT_OFFSET;
    labelFrame.origin.y = CELL_TOP_OFFSET;
    labelFrame.size.width = cellWidth-CELL_RIGHT_OFFSET-CELL_LEFT_OFFSET;
    label.frame = labelFrame;
    [label sizeToFit];
    return label;
}
-(void) createTableView:(CGFloat) leftOffset rightOffset:(CGFloat) rightOffset
{
    [documentTitle removeFromSuperview];
    [documentTitle release];
    [tableView removeFromSuperview];
    [tableView release];
    
    CGRect viewRect = self.view.bounds;
    CGRect tableViewRect = CGRectMake(leftOffset, 0, viewRect.size.width+rightOffset, viewRect.size.height);
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
    [self.view addSubview:tableView];}
@end
