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
#import "Attachment.h"

@interface  DocumentInfoViewController(Private)
-(void) recalcSize;
@end


@implementation DocumentInfoViewController

#pragma mark -
#pragma mark Properties
@synthesize document, attachment;


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
    
    currentItems = unmanagedDocument.attachments;
    
    documentTitle.text = document.title;
    documentDetails.text = [NSString stringWithFormat:@"%@, %@", document.author, [dateFormatter stringFromDate: document.dateModified]];
    [self recalcSize];
    [self.tableView reloadData];
    NSArray *attachments = unmanagedDocument.attachments;
    if ([attachments count]) 
    {
        Attachment *firstAttachment = [attachments objectAtIndex:0];
        self.attachment = firstAttachment;
    }
    else
        self.attachment = nil;
    
    if (![unmanagedDocument.links count])
        filter.hidden = YES;
    else
        filter.hidden = NO;

    filter.selectedSegmentIndex = 0;
    [filter sizeToFit];
    CGRect filterFrame = filter.frame;
    filter.frame = CGRectMake((documentTitle.frame.size.width - filterFrame.size.width)/2, 99, filterFrame.size.width, filterFrame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //clear table background
    //http://useyourloaf.com/blog/2010/7/21/ipad-table-backgroundview.html
    UIImageView *bg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Paper.png"]];
    self.tableView.backgroundView = bg;
    [bg release];
    //    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 60.0f;
    
    //create table header
    //http://cocoawithlove.com/2009/04/easy-custom-uiself.tableView-drawing.html
    UIView *containerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 157)];
    documentTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 33, 0, 48)];
    documentTitle.textColor = [UIColor blackColor];
    documentTitle.textAlignment = UITextAlignmentCenter;
    documentTitle.font = [UIFont fontWithName:@"CharterC" size:24];
    documentTitle.backgroundColor = [UIColor clearColor];
    documentTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:documentTitle];
    
    documentDetails = [[UILabel alloc] initWithFrame:CGRectMake(0, 57, 300, 48)];
    documentDetails.textColor = [UIColor darkGrayColor];
    documentDetails.textAlignment = UITextAlignmentCenter;
    documentDetails.font = [UIFont fontWithName:@"CharterC" size:14];
    documentDetails.backgroundColor = [UIColor clearColor];
    documentDetails.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:documentDetails];
    
    filter = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:NSLocalizedString(@"Files", "Files"),
                                                        NSLocalizedString(@"Linked files", "Linked files"),
                                                         nil]];
    [filter sizeToFit];
    filter.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);

    filter.selectedSegmentIndex = 0;
    [filter addTarget:self action:@selector(switchFilter:) forControlEvents:UIControlEventValueChanged];
    filter.segmentedControlStyle = UISegmentedControlStyleBar;
    CGRect filterFrame = filter.frame;
    filter.frame = CGRectMake((documentTitle.frame.size.width - filterFrame.size.width)/2, 99, filterFrame.size.width, filterFrame.size.height);
    [containerView addSubview:filter];
    self.tableView.tableHeaderView = containerView;
    [containerView release];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view = self.tableView;    
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    if (![unmanagedDocument.links count])
        filter.hidden = YES;
    else
        filter.hidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [documentTitle release];
    documentTitle = nil;
    [documentDetails release];
    documentDetails = nil;
    [filter release];
    filter = nil;
    [dateFormatter release];
    dateFormatter = nil;
}
#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.attachment = [currentItems objectAtIndex:indexPath.row];
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentItems count];
}

- (UITableViewCell *)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = nil;
    
    static NSString *cellIdentifier = @"AttachmentCell";

    cell = [self.tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: cellIdentifier] autorelease];
        UIImageView *selectedRowBackground = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"DocumentInfoSelectedCell.png"]];
        cell.selectedBackgroundView = selectedRowBackground;
        [selectedRowBackground release];
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.detailTextLabel.highlightedTextColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }
    Attachment *a = [currentItems objectAtIndex:indexPath.row];
    cell.textLabel.text = a.title;
    NSUInteger count = [a.pages count];
    NSString *pageLabel = count==1?NSLocalizedString(@"page", "page"):(count < 5?NSLocalizedString(@"pages_genetivus", "pages in genetivus"):NSLocalizedString(@"pages", "pages"));
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", [a.pages count], pageLabel];
    return cell;
}

- (void)dealloc {
    self.document = nil;
    [unmanagedDocument release];

    [documentTitle release];
    documentTitle = nil;
    [documentDetails release];
    documentDetails = nil;
    [filter release];
    filter = nil;
    [dateFormatter release];
    dateFormatter = nil;
    self.attachment = nil;
    [super dealloc];
}

#pragma mark - 
#pragma mark actions
-(void) switchFilter:(id) sender
{
    switch(filter.selectedSegmentIndex)
    {
        case 0:
            currentItems = unmanagedDocument.attachments;
            break;
        case 1:
            currentItems = unmanagedDocument.links;
            break;
        default:
            NSAssert1 (NO, @"Invalid filter value: %d", filter.selectedSegmentIndex);
    }
    [self.tableView reloadData];
}
@end

@implementation  DocumentInfoViewController(Private)
-(void) recalcSize
{
    NSUInteger numberOfRows = MAX([unmanagedDocument.attachments count], [unmanagedDocument.links count]);
    
    if (!numberOfRows)
        numberOfRows = 1;
    
    CGRect headerFrame = self.tableView.tableHeaderView.frame;
    
    CGFloat height = headerFrame.size.height+numberOfRows*self.tableView.rowHeight;
    CGRect viewFrame = self.view.frame;
    self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, height);
    
    self.tableView.tableHeaderView.frame = CGRectMake(headerFrame.origin.x, headerFrame.origin.y, viewFrame.size.width, headerFrame.size.height);
    
    CGRect titleFrame = documentTitle.frame;
    documentTitle.frame = CGRectMake(titleFrame.origin.x, titleFrame.origin.y, viewFrame.size.width, titleFrame.size.height);

    CGRect detailsFrame = documentDetails.frame;
    documentDetails.frame = CGRectMake(detailsFrame.origin.x, detailsFrame.origin.y, viewFrame.size.width, detailsFrame.size.height);
    
    CGRect filterFrame = filter.frame;
    filter.frame = CGRectMake((viewFrame.size.width-filterFrame.size.width)/2, filterFrame.origin.y, filterFrame.size.width, filterFrame.size.height);
}
@end
