    //
//  DocumentViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentViewController.h"
#import "SwitchViewController.h"
#import "DocumentCell.h"
#import "Document.h"
#import "AttachmentsViewController.h"

static NSString * DocumentCellIdentifier = @"DocumentCellIdentifier";

@implementation DocumentViewController

@synthesize switchViewController, documentTitle, attachmentsViewController;
    // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
	self.docListView.delegate = self;
    self.docListView.layoutDirection = AQGridViewLayoutDirectionHorizontal;
    [self.docListView reloadData];
}

- (void)dealloc {
    self.switchViewController = nil;
    self.document = nil;
    [super dealloc];
}

- (void) showDocumentList:(id) sender
{
    [self.switchViewController listDocuments];
}

@dynamic document;

- (Document *) document
{
    return _document;
}

- (void) setDocument:(Document *) aDocument
{
    if (_document == aDocument)
        return;
    [_document release];
    _document = [aDocument retain];
    documentTitle.text = _document.title;
    attachmentsViewController.document = _document;
}

#pragma mark -
#pragma mark Grid View Delegate
- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    DocumentCell *cell = (DocumentCell *)[gridView cellForItemAtIndex: index];
    self.document = cell.document;
}
@end
