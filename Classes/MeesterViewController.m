//
//  MeesterViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "MeesterViewController.h"
#import "DocumentCell.h"
#import "Document.h"

@implementation MeesterViewController
@synthesize docListView = _docListView;
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

    DocumentCellChooser * chooser = [[DocumentCellChooser alloc] initWithItemTitles: [NSArray arrayWithObjects: NSLocalizedString(@"Plain", @""), NSLocalizedString(@"Filled", @""), nil]];
    chooser.delegate = self;
    [chooser release];

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

#pragma mark -
#pragma mark DocumentCellChooser delegates

- (void) cellChooser: (DocumentCellChooser *) chooser selectedItemAtIndex: (NSUInteger) index
{
    self.docListView.separatorStyle = AQGridViewCellSeparatorStyleSingleLine;
    self.docListView.resizesCellWidthToFit = YES;
    self.docListView.separatorColor = [UIColor colorWithWhite: 0.85 alpha: 1.0];

    [self.docListView reloadData];
}
    
#pragma mark -
#pragma mark Grid View Data Source

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

// nothing here yet
@end
