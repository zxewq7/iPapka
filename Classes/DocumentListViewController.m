//
//  MeesterViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentListViewController.h"
#import "DocumentCell.h"
#import "Document.h"
#import "SwitchViewController.h"

@implementation DocumentListViewController
@synthesize docListView;
@synthesize switchViewController;

static NSString * DocumentCellIdentifier = @"DocumentCellIdentifier";

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.docListView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.docListView.autoresizesSubviews = YES;
	self.docListView.delegate = self;
	self.docListView.dataSource = self;
    self.docListView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocListBackground.jpg"]];

    if ( _documents != nil )
        return;

#warning fake data
    _documents = [[NSMutableArray alloc] init];
    [_documents retain];
    
    for(int i=0;i<100;i++)
    {
        Document *document = [[Document alloc] init];
        document.icon =  [UIImage imageNamed: @"Signature.png"];
        document.title = [NSString stringWithFormat:@"Document #%d", i];
        document.uid = [NSString stringWithFormat:@"document #%d", i];
        [_documents addObject:document];
        [document release];
    }
    
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
    self.docListView = nil;
}


- (void)dealloc {
    self.docListView=nil;
    [_documents release];
    [super dealloc];
}

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return ( [_documents count] );
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
            
    filledCell.document = [_documents objectAtIndex:index];
            
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
    [self.switchViewController showDocument:(Document *)[_documents objectAtIndex:index]];
}
@end
