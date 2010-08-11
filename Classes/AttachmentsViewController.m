//
//  AttachmetsViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttachmentsViewController.h"
#import "Document.h"
#import "AttachmentCell.h"

static NSString * AttachmentCellIdentifier = @"AttachmentCellIdentifier";

@implementation AttachmentsViewController
@synthesize attachmentListView;

-(void)dealloc
{
    self.attachmentListView = nil;
    self.document = nil;
    [super dealloc];
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
    self.attachmentListView.layoutDirection = AQGridViewLayoutDirectionHorizontal;
    [self.attachmentListView reloadData];
}
#pragma mark -
#pragma mark Grid View Data Source
- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return ( [self.document.attachments count] );
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    AQGridViewCell * cell = nil;
    
    AttachmentCell * filledCell = (AttachmentCell *)[aGridView dequeueReusableCellWithIdentifier: AttachmentCellIdentifier];
    if ( filledCell == nil )
    {
        filledCell = [[[AttachmentCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 200.0, 150.0)
                                          reuseIdentifier: AttachmentCellIdentifier] autorelease];
        filledCell.selectionStyle = AQGridViewCellSelectionStyleBlueGray;
    }
    
    filledCell.attachment = [self.document.attachments objectAtIndex:index];
    
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
    
}
@end
