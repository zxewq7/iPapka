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
    [tableView reloadData];
    NSArray *attachments = unmanagedDocument.attachments;
    if ([attachments count]) 
    {
        Attachment *firstAttachment = [attachments objectAtIndex:0];
        self.attachment = firstAttachment;
    }
}

- (void)loadView
{
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    //clear table background
    //http://useyourloaf.com/blog/2010/7/21/ipad-table-backgroundview.html
    UIImageView *bg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Paper.png"]];
    tableView.backgroundView = bg;
    [bg release];
//    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.rowHeight = 60.0f;
    
    //create table header
    //http://cocoawithlove.com/2009/04/easy-custom-uitableview-drawing.html
    UIView *containerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 157)];
    documentTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, 48)];
    documentTitle.textColor = [UIColor blackColor];
    documentTitle.textAlignment = UITextAlignmentCenter;
    documentTitle.font = [UIFont boldSystemFontOfSize:24];
    documentTitle.backgroundColor = [UIColor clearColor];
    [containerView addSubview:documentTitle];

    documentDetails = [[UILabel alloc] initWithFrame:CGRectMake(10, 20+48, 300, 48)];
    documentDetails.textColor = [UIColor darkGrayColor];
    documentDetails.textAlignment = UITextAlignmentCenter;
    documentDetails.font = [UIFont boldSystemFontOfSize:14];
    documentDetails.backgroundColor = [UIColor clearColor];
    [containerView addSubview:documentDetails];

    filter = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:NSLocalizedString(@"Files", "Files"),
                                                                             NSLocalizedString(@"Linked files", "Linked files"),
                                                                             nil]];
    CGRect filterFrame = filter.frame;
    filter.frame = CGRectMake(10, 20+48+48, filterFrame.size.width, 30);
    [containerView addSubview:filter];
    tableView.tableHeaderView = containerView;
    [containerView release];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    self.view = tableView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
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

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = nil;
    
    static NSString *cellIdentifier = @"AttachmentCell";

    cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: cellIdentifier] autorelease];
        UIImageView *selectedRowBackground = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"DocumentInfoSelectedCell.png"]];
        cell.selectedBackgroundView = selectedRowBackground;
    }
    Attachment *a = [currentItems objectAtIndex:indexPath.row];
    cell.textLabel.text = a.title;
    return cell;
}

- (void)dealloc {
    self.document = nil;
    [unmanagedDocument release];

    [tableView release];
    tableView = nil;
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
@end

@implementation  DocumentInfoViewController(Private)
-(void) recalcSize
{
    NSUInteger numberOfRows = MAX([unmanagedDocument.attachments count], [unmanagedDocument.links count]);
    
    if (!numberOfRows)
        numberOfRows = 1;
    
    CGRect headerFrame = tableView.tableHeaderView.frame;
    
    CGFloat height = headerFrame.size.height+numberOfRows*tableView.rowHeight;
    CGRect viewFrame = self.view.frame;
    self.view.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, height);
    
    tableView.tableHeaderView.frame = CGRectMake(headerFrame.origin.x, headerFrame.origin.y, viewFrame.size.width, headerFrame.size.height);
    
    CGRect titleFrame = documentTitle.frame;
    documentTitle.frame = CGRectMake(titleFrame.origin.x, titleFrame.origin.y, viewFrame.size.width, titleFrame.size.height);

    CGRect detailsFrame = documentDetails.frame;
    documentDetails.frame = CGRectMake(detailsFrame.origin.x, detailsFrame.origin.y, viewFrame.size.width, detailsFrame.size.height);
    
    CGRect filterFrame = filter.frame;
    filter.frame = CGRectMake((viewFrame.size.width-filterFrame.size.width)/2, filterFrame.origin.y, filterFrame.size.width, filterFrame.size.height);
}
@end
