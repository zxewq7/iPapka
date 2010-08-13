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
#import "LNDataSource.h"

@interface DocumentListViewController(Private)
- (void)documentsAdded:(NSNotification *)notification;
- (void)documentsRemoved:(NSNotification *)notification;
@end
@implementation DocumentListViewController
@synthesize docListView, switchViewController, allDocuments, sortDescriptors;

static NSString * DocumentCellIdentifier = @"DocumentCellIdentifier";

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.docListView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.docListView.autoresizesSubviews = YES;
	self.docListView.delegate = self;
	self.docListView.dataSource = self;
    self.docListView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocListBackground.jpg"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(documentsAdded:)
                                          name:@"DocumentsAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(documentsRemoved:)
                                          name:@"DocumentsRemoved" object:nil];
    self.allDocuments = [NSMutableArray array];
    [self.allDocuments addObjectsFromArray:[[LNDataSource sharedLNDataSource].documents allValues]];
    
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                 ascending:YES];
    self.allDocuments = [NSMutableArray arrayWithArray:[[LNDataSource sharedLNDataSource].documents allValues]];
    self.sortDescriptors = [NSArray arrayWithObject:titleDescriptor];
    [titleDescriptor release];
    [self.allDocuments sortedArrayUsingDescriptors:self.sortDescriptors];
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
    [allDocuments release];
    [super dealloc];
}

#pragma mark -
#pragma mark Grid View Data Source
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return ( [self.allDocuments count] );
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
            
    filledCell.document = [self.allDocuments objectAtIndex:index];
            
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
    [self.switchViewController showDocument:(Document *)[allDocuments objectAtIndex:index]];
    [gridView deselectItemAtIndex:index animated:NO];
}
@end

@implementation DocumentListViewController(Private)
- (void)documentsAdded:(NSNotification *)notification
{
    NSArray *documents = notification.object;
    [self.allDocuments addObjectsFromArray:documents];
    [self.allDocuments sortedArrayUsingDescriptors:self.sortDescriptors];
    
    NSMutableIndexSet *indicies = [NSMutableIndexSet indexSet];
    for(Document *document in documents)
    {
        NSUInteger index = [self.allDocuments indexOfObject:document];
        if (index != NSNotFound)
            [indicies addIndex:index];
    }
    if ([indicies count])
        [docListView insertItemsAtIndices: indicies withAnimation: AQGridViewItemAnimationRight];
}

- (void)documentsRemoved:(NSNotification *)notification
{
    NSArray *documents = notification.object;
    NSMutableIndexSet *indicies = [NSMutableIndexSet indexSet];
    for(Document *document in documents)
    {
        NSUInteger index = [self.allDocuments indexOfObject:document];
        if (index != NSNotFound)
            [indicies addIndex:index];
    }
    if ([indicies count])
    {
        [allDocuments removeObjectsAtIndexes:indicies];
        [docListView deleteItemsAtIndices: indicies withAnimation: AQGridViewItemAnimationFade];
    }
}
@end
