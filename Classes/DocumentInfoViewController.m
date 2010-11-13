    //
//  DocumentInfoViewController.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentInfoViewController.h"
#import "Document.h"
#import "Attachment.h"
#import "Person.h"
#import "DocumentResolution.h"
#import "DocumentInfoView.h"
#import "AZZSegmentedLabel.h"

#define kMinTableRows 4

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
- (void)loadView
{
    documentInfo = [[DocumentInfoView alloc] initWithFrame:CGRectZero];
    self.view = documentInfo;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    //filter
    filter = documentInfo.filterView;
    [filter retain];
    [filter insertSegmentWithTitle:NSLocalizedString(@"Files", "Files") atIndex:0 animated:NO];
    [filter insertSegmentWithTitle:NSLocalizedString(@"Linked files", "Linked files") atIndex:1 animated:NO];

    filter.selectedSegmentIndex = 0;

    [filter addTarget:self action:@selector(switchFilter:) forControlEvents:UIControlEventValueChanged];

    tableView = documentInfo.tableView;
    
    [tableView retain];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self updateContent];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [documentInfo release]; documentInfo = nil;
    [filter release]; filter = nil;
    [dateFormatter release]; dateFormatter = nil;
    [tableView release]; tableView = nil;
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

    [documentInfo release]; documentInfo = nil;
    
    [filter release]; filter = nil;
    
    [dateFormatter release]; dateFormatter = nil;
    
    [tableView release]; tableView = nil;
    
    [currentItems release]; currentItems = nil;

    [super dealloc];
}

#pragma mark - 
#pragma mark actions
-(void) switchFilter:(id) sender
{
    [currentItems release]; currentItems = nil;
    
    switch(filter.selectedSegmentIndex)
    {
        case 0:
            currentItems = document.attachmentsOrdered;
            [currentItems retain];
            break;
        case 1:
            currentItems = document.linksOrdered;
            [currentItems retain];
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
    [currentItems release];
    currentItems = document.attachmentsOrdered;
    [currentItems retain];
    
    documentInfo.textLabel.text = document.title;

    NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:4];
    BOOL isPriority = (document.priorityValue > 0);
    BOOL isStatus = NO;
    
    if (isPriority)
        [labels addObject: [NSLocalizedString(@"Important", @"Important") uppercaseString]];
    else
        [labels addObject: @""];
    
    switch (document.statusValue)
    {
        case DocumentStatusAccepted:
            [labels addObject: @""];
            
            if (isPriority)
                [labels addObject: [@" " stringByAppendingString:[NSLocalizedString(@"Accepted", @"Accepted") uppercaseString]]];
            else
                [labels addObject: [NSLocalizedString(@"Accepted", @"Accepted") uppercaseString]];
            
            isStatus = YES;
            break;
        case DocumentStatusDeclined:
            if (isPriority)
                [labels addObject: [@" " stringByAppendingString:[NSLocalizedString(@"Declined", @"Declined") uppercaseString]]];
            else
                [labels addObject: [NSLocalizedString(@"Declined", @"Declined") uppercaseString]];
            
            [labels addObject: @""];
            
            isStatus = YES;
            break;
        default:
            [labels addObject: @""];
            [labels addObject: @""];
            break;
    }
    
    documentInfo.detailTextLabel1.texts = labels;
    
    NSString *details;
    
    if (!document)
        details = nil;
    else if ([document isKindOfClass:[DocumentResolution class]])
    {
        if ([document.correspondents count])
            details = [NSString stringWithFormat:@"%@ %@ %@, %@", document.registrationNumber, NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: document.registrationDate], [document.correspondents componentsJoinedByString:@", "]];
        else
            details = [NSString stringWithFormat:@"%@ %@ %@", document.registrationNumber, NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: document.registrationDate]];
    }
    else if ([document.correspondents count])
        details = [NSString stringWithFormat:@"%@ %@, %@",  NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: document.registrationDate], [document.correspondents componentsJoinedByString:@", "]];
    else
        details = [NSString stringWithFormat:@"%@ %@",  NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: document.registrationDate]];
    
    
    documentInfo.detailTextLabel2.text = (isStatus || isPriority)? [@", " stringByAppendingString:details]:details;

    if ([currentItems count]) 
        attachmentIndex = 0;
    else
        attachmentIndex = NSNotFound;
    
    if (![document.links count])
        filter.hidden = YES;
    else
        filter.hidden = NO;
    
    filter.selectedSegmentIndex = 0;
    
    [self.view setNeedsLayout];
    
    [tableView reloadData];
}
@end
