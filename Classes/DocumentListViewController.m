//
//  MeesterViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentListViewController.h"
#import "Document.h"
#import "SwitchViewController.h"
#import "DocumentCell.h"

@implementation DocumentListViewController
@synthesize switchViewController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
	self.docListView.delegate = self;
    [self.docListView reloadData];
}

- (void)dealloc {
    self.switchViewController = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Grid View Delegate
- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    DocumentCell *cell = (DocumentCell *)[gridView cellForItemAtIndex: index];
    [self.switchViewController showDocument:cell.document];
    [gridView deselectItemAtIndex:index animated:NO];
}
@end