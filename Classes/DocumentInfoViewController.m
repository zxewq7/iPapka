    //
//  DocumentInfoViewController.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentInfoViewController.h"
#import "Attachment.h"
#import "Person.h"
#import "DocumentResolution.h"
#import "DocumentInfoView.h"
#import "AZZSegmentedLabel.h"
#import "DocumentWithResources.h"
#import "DocumentLink.h"
#import "DocumentSignature.h"

#define kMinTableRows 4

@interface  DocumentInfoViewController(Private)
-(void) updateContent;
@end


@implementation DocumentInfoViewController

#pragma mark -
#pragma mark Properties
@synthesize document, attachment, link;


-(void) setDocument:(DocumentWithResources *) aDocument
{
    if (document != aDocument)
    {
        [document release];
        document = [aDocument retain];
    }
    
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
        self.link = (DocumentLink *)file;
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
        DocumentLink *d = (DocumentLink *) file;
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
            currentItems = ((DocumentWithResources *)document).linksOrdered;
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
    
    NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:4];

    if ([self.document isKindOfClass:[DocumentRoot class]])
    {
        DocumentRoot *doc = (DocumentRoot *)self.document;

        documentInfo.textLabel.text = doc.title;

        
        BOOL isPriority = (doc.priorityValue > 0);
        BOOL isStatus = NO;
        
        if (isPriority)
            [labels addObject: [NSLocalizedString(@"Important", @"Important") uppercaseString]];
        else
            [labels addObject: @""];
        
        switch (doc.statusValue)
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
        
        NSString *details = nil;
        
        if ([self.document isKindOfClass:[DocumentResolution class]])
        {
            DocumentResolution *resolution = (DocumentResolution *) self.document;
            
            if ([resolution.correspondents count])
                details = [NSString stringWithFormat:@"%@ %@ %@, %@", resolution.regNumber, NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: resolution.regDate], [resolution.correspondents componentsJoinedByString:@", "]];
            else
                details = [NSString stringWithFormat:@"%@ %@ %@", resolution.regNumber, NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: resolution.regDate]];
        }
        else if ([self.document isKindOfClass:[DocumentSignature class]])
        {
            DocumentSignature *signature = (DocumentSignature *) self.document;
            if ([signature.correspondents count])
            {
                details = [NSString stringWithFormat:@"%@ %@, %@",  NSLocalizedString(@"from", @"from"), [dateFormatter stringFromDate: signature.received], [signature.correspondents componentsJoinedByString:@", "]];
            }
        }
        else
            NSAssert1(NO, @"invalid class %@", [self.document class]);
            
        documentInfo.detailTextLabel2.text = (isStatus || isPriority)? [@", " stringByAppendingString:details]:details;
        
        if (![doc.links count])
            filter.hidden = YES;
        else
            filter.hidden = NO;
        
    }
    else if ([self.document isKindOfClass:[DocumentLink class]] || (self.document == nil))
    {
        DocumentLink *doc = (DocumentLink *)self.document;
        
        documentInfo.textLabel.text = ((DocumentRoot *)doc.document).title;
        
        for (int i = 0; i < 4; i++)
            [labels addObject:@""];
        
        documentInfo.detailTextLabel2.text = doc.title;
        
        filter.hidden = YES;
    }

    
    documentInfo.detailTextLabel1.texts = labels;
    
    [labels release];
    
    if ([currentItems count]) 
        attachmentIndex = 0;
    else
        attachmentIndex = NSNotFound;
    
    filter.selectedSegmentIndex = 0;
    
    [self.view setNeedsLayout];
    
    [tableView reloadData];
}
@end
