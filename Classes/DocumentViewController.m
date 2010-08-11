    //
//  DocumentViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentViewController.h"
#import "SwitchViewController.h"
#import "LNDataSource.h"
#import "DocumentCell.h"
#import "Document.h"

static NSString * DocumentCellIdentifier = @"DocumentCellIdentifier";

@implementation DocumentViewController

@synthesize switchViewController, docListView, documentTitle;
    // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.docListView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.docListView.autoresizesSubviews = YES;
	self.docListView.delegate = self;
	self.docListView.dataSource = self;
    self.docListView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocListBackground.jpg"]];
    self.docListView.layoutDirection = AQGridViewLayoutDirectionHorizontal;
    _dataController = [LNDataSource sharedLNDataSource];
    [self.docListView reloadData];
}


    // Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
        // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
        // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.docListView = nil;
}


- (void)dealloc {
    self.docListView=nil;
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
}
#pragma mark -
#pragma mark Grid View Data Source
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return ( [_dataController count] );
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    AQGridViewCell * cell = nil;
    
    DocumentCell * filledCell = (DocumentCell *)[aGridView dequeueReusableCellWithIdentifier: DocumentCellIdentifier];
    if ( filledCell == nil )
    {
        filledCell = [[[DocumentCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 200.0, 150.0)
                                          reuseIdentifier: DocumentCellIdentifier] autorelease];
        filledCell.selectionStyle = AQGridViewCellSelectionStyleBlueGray;
    }
    
    filledCell.document = [_dataController documentAtIndex:index];
    
    cell = filledCell;
    
    return ( cell );
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(224.0, 168.0) );
}

#pragma mark -
#pragma mark Grid View Delegate
- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    self.document = [_dataController documentAtIndex:index];
}
@end
