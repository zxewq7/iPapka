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
#import "Document.h"
#import "Attachment.h"
#import "ImageScrollView.h"
#import "AttachmentsViewController.h"

@implementation DocumentViewController

#pragma mark -
#pragma mark Properties
@synthesize toolbar, document, documentTitle;


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
    
    NSArray *attachments = document.document.attachments;
    if ([attachments count]) 
    {
        Attachment *firstAttachment = [attachments objectAtIndex:0];
        attachmentsViewController.attachment = firstAttachment;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (document == nil) 
        documentTitle.title = nil;

    CGRect viewRect = self.view.bounds;
    CGRect toolbarRect = self.toolbar.bounds;
    
    CGRect scrollViewRect = CGRectMake(0, viewRect.origin.y + toolbarRect.size.height, viewRect.size.width, viewRect.size.height - toolbarRect.size.height);
    attachmentsViewController = [[AttachmentsViewController alloc] initWithFrame:scrollViewRect];

    [self.view addSubview: attachmentsViewController.view];
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocumentViewBackground.png"]];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];
    [self.view addSubview:attachmentsViewController.view];
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
    self.toolbar = nil;
    [super viewDidUnload];
    [attachmentsViewController release];
    attachmentsViewController = nil;
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

- (void)dealloc {
    self.toolbar = nil;
    self.document = nil;
    self.documentTitle = nil;
    [attachmentsViewController release];
    
    [super dealloc];
}
@end
