    //
//  DocumentViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentViewController.h"
#import "Document.h"

@implementation DocumentViewController

#pragma mark -
#pragma mark Properties
@synthesize toolbar, document, documentTitle;


-(void) setDocument:(Document *) aDocument
{
    if (document == aDocument)
        return;
    [document release];
    document = [aDocument retain];
    
    documentTitle.title = document.title;
    if (![document.isRead boolValue])
        document.isRead = [NSNumber numberWithBool:YES];
}

 - (void)viewDidLoad
{
     [super viewDidLoad];
     
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
        // Release any retained subviews of the main view.
        // e.g. self.myOutlet = nil;
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
    [super dealloc];
}
@end
