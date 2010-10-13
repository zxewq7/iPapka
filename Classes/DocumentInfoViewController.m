    //
//  DocumentInfoViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentInfoViewController.h"
#import "Document.h"
#import "Attachment.h"
#import "Person.h"
#import <QuartzCore/CALayer.h>

#define kMinTableRows 4
#define kTableRowHeight 60.0f

@interface  DocumentInfoViewController(Private)
-(void) updateContent;
@end


@implementation DocumentInfoViewController

#pragma mark -
#pragma mark Properties
@synthesize document, attachment, link;


-(void) setDocument:(Document *) aDocument
{
    if (document == aDocument)
        return;
    [document release];
    document = [aDocument retain];
    
    [self updateContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    CGSize viewSize = self.view.bounds.size;
    
    //create header
    CGRect containerViewFrame = CGRectMake(0, 0, viewSize.width, 157);
    UIView *containerView =[[UIView alloc] initWithFrame: containerViewFrame];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    containerView.userInteractionEnabled = YES;
    
    documentTitle = [[UILabel alloc] initWithFrame: CGRectZero];
    documentTitle.text = @"Test";
    documentTitle.textColor = [UIColor blackColor];
    documentTitle.textAlignment = UITextAlignmentCenter;
    documentTitle.font = [UIFont fontWithName:@"CharterC" size:24];
    documentTitle.backgroundColor = [UIColor clearColor];
    
    documentTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [documentTitle sizeToFit];

    CGRect documentTitleFrame = documentTitle.frame;

    documentTitleFrame.origin.x = 0;
    documentTitleFrame.origin.y = 48.0f;
    documentTitleFrame.size.width = containerViewFrame.size.width;
    
    documentTitle.frame = documentTitleFrame;
    
    [containerView addSubview:documentTitle];
    
    documentDetails = [[UILabel alloc] initWithFrame:CGRectZero];
    documentDetails.text = @"Test";
    documentDetails.textColor = [UIColor darkGrayColor];
    documentDetails.textAlignment = UITextAlignmentCenter;
    documentDetails.font = [UIFont fontWithName:@"CharterC" size:14];
    documentDetails.backgroundColor = [UIColor clearColor];
    
    [documentDetails sizeToFit];
    
    CGRect documentDetailsFrame = documentDetails.frame;
    documentDetailsFrame.origin.x = 0;
    documentDetailsFrame.origin.y = documentTitleFrame.origin.y + documentTitleFrame.size.height + 8.0f;
    documentDetailsFrame.size.width = containerViewFrame.size.width;
    documentDetails.frame = documentDetailsFrame;
    
    documentDetails.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:documentDetails];
    
    //filter
    filter = [[UISegmentedControl alloc] initWithItems: [NSArray arrayWithObjects:NSLocalizedString(@"Files", "Files"),
                                                        NSLocalizedString(@"Linked files", "Linked files"),
                                                         nil]];
    filter.segmentedControlStyle = UISegmentedControlStyleBar;
    
    filter.userInteractionEnabled = YES;

    [filter sizeToFit];
    CGRect filterFrame = filter.frame;
    filterFrame.origin.x = (documentTitle.frame.size.width - filterFrame.size.width)/2;
    filterFrame.origin.y = documentDetailsFrame.origin.y + documentDetailsFrame.size.height + 20.0f;
    filter.frame = filterFrame;
    filter.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);

    [filter addTarget:self action:@selector(switchFilter:) forControlEvents:UIControlEventValueChanged];

    filter.selectedSegmentIndex = 0;
    
    [containerView addSubview: filter];
    
    [self.view addSubview: containerView];

    [containerView release];
    
    CGRect tableViewFrame = CGRectMake(containerViewFrame.origin.x, containerViewFrame.size.height + containerViewFrame.origin.y, containerViewFrame.size.width, kMinTableRows * kTableRowHeight);
    tableView = [[UITableView alloc] initWithFrame:tableViewFrame style: UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tableView.layer.borderWidth = 1.0f;
    tableView.layer.borderColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.0].CGColor;
    

    
    //clear table background
    //http://useyourloaf.com/blog/2010/7/21/ipad-table-backgroundview.html
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.rowHeight = kTableRowHeight;

    [self.view addSubview: tableView];
    
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height = tableView.frame.origin.y + tableViewFrame.size.height;
    self.view.frame = viewFrame;

    [self updateContent];
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
    [tableView release];
    tableView = nil;
}
#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject  *file = [currentItems objectAtIndex:indexPath.row];
    if ([file isKindOfClass: [Attachment class]])
        self.attachment = (Attachment *)file;
    else
        self.link = (Document *)file;
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentItems count];
}

- (UITableViewCell *)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject  *file = [currentItems objectAtIndex:indexPath.row];
    
    BOOL isAttachment = [file isKindOfClass: [Attachment class]];
    
    UITableViewCell *cell = nil;
    
    static NSString *attachmentIdentifier = @"AttachmentCell";
    
    static NSString *linkIdentifier = @"LinkCell";
    
    NSString *cellIdentifier = isAttachment?attachmentIdentifier:linkIdentifier;

    cell = [tv dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle: (isAttachment?UITableViewCellStyleSubtitle:UITableViewCellStyleDefault) reuseIdentifier: cellIdentifier] autorelease];
        UIImageView *selectedRowBackground = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"DocumentInfoSelectedCell.png"]];
        cell.selectedBackgroundView = selectedRowBackground;
        [selectedRowBackground release];
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.detailTextLabel.highlightedTextColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }
    if (isAttachment)
    {
        Attachment *a = (Attachment *) file;
        cell.textLabel.text = a.title;
        NSUInteger count = [a.pages count];
        NSString *pageLabel = count==1?NSLocalizedString(@"page", "page"):(count < 5?NSLocalizedString(@"pages_2-4_instrumentalis", "pages from 2 to 4 in instrumentalis"):NSLocalizedString(@"pages_instrumentalis", "pages_instrumentalis"));
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", [a.pages count], pageLabel];
    }
    else
    {
        Document *d = (Document *) file;
        cell.textLabel.text = d.title;
    }
    return cell;
}

- (void)dealloc {
    self.document = nil;
    self.link = nil;
    self.attachment = nil;

    [documentTitle release]; documentTitle = nil;
    
    [documentDetails release]; documentDetails = nil;
    
    [filter release]; filter = nil;
    
    [dateFormatter release]; dateFormatter = nil;
    
    [tableView release]; tableView = nil;

    [super dealloc];
}

#pragma mark - 
#pragma mark actions
-(void) switchFilter:(id) sender
{
    switch(filter.selectedSegmentIndex)
    {
        case 0:
            currentItems = document.attachmentsOrdered;
            break;
        case 1:
            currentItems = document.linksOrdered;
            break;
        default:
            NSAssert1 (NO, @"Invalid filter value: %d", filter.selectedSegmentIndex);
    }
    [tableView reloadData];
}
@end

@implementation  DocumentInfoViewController(Private)
-(void) updateContent;
{
    currentItems = document.attachmentsOrdered;
    
    documentTitle.text = document.title;
    documentDetails.text = [NSString stringWithFormat:@"%@, %@", document.author, [dateFormatter stringFromDate: document.dateModified]];
    if ([currentItems count]) 
        attachmentIndex = 0;
    else
        attachmentIndex = NSNotFound;
    
    if (![document.links count])
        filter.hidden = YES;
    else
        filter.hidden = NO;
    
    filter.selectedSegmentIndex = 0;
    
    [tableView reloadData];
}
@end
