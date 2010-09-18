//
//  PerformersViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PerformersViewController.h"
#import "ViewWithButtons.h"
#import "UIButton+Additions.h"
#import "ResolutionManaged.h"
#import "Resolution.h"
#import "PersonManaged.h"

@interface PerformersViewController (Private)
- (void) updateContent;
@end

@implementation PerformersViewController
@synthesize document;

-(void) setDocument:(ResolutionManaged *) aDocument
{
    if (document == aDocument)
        return;

    [document release];
    
    document = [aDocument retain];
    
    if (document)
    {
        NSSet *ps = document.performers;
        performers = [[NSMutableArray alloc] initWithCapacity:[ps count]];
        for (PersonManaged *p in ps)
            [performers addObject: p];
        
        [performers sortedArrayUsingDescriptors: sortByLastDescriptors];
    }
    else
        performers = nil;
    
    [self updateContent];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    NSSortDescriptor *sortDescriptor = 
    [[NSSortDescriptor alloc] initWithKey:@"last" 
                                ascending:YES];
    
    sortByLastDescriptors = [[NSArray alloc] 
                                initWithObjects:sortDescriptor, nil];  
    [sortDescriptor release];
    
    CGSize viewSize = self.view.bounds.size;
    
    performersView = [[ViewWithButtons alloc] initWithFrame: CGRectMake(0, 0, viewSize.width - 50, viewSize.height)];
    
    performersView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    performersView.spaceBetweenButtons = 1.0f;
    performersView.spaceBetweenRows = 1.0f;
    
    performersView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview: performersView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)viewDidUnload {
    [super viewDidUnload];

    [performersView release];
    performersView = nil;

    [sortByLastDescriptors release];
    sortByLastDescriptors = nil;
}


- (void)dealloc 
{
    self.document = nil;

    [performers release];
    performers = nil;

    [performersView release];
    performersView = nil;

    [sortByLastDescriptors release];
    sortByLastDescriptors = nil;

    [super dealloc];
}

#pragma Private

- (void) updateContent
{
    NSMutableArray *performerButtons = [NSMutableArray arrayWithCapacity: [performers count]];
    
    for (PersonManaged *performer in performers)
    {
        [performerButtons addObject: [UIButton buttonWithBackgroundAndTitle:performer.fullName
                                                                  titleFont:[UIFont fontWithName:@"CharterC" size:16]
                                                                     target:self
                                                                   selector:nil
                                                                      frame:CGRectMake(0, 0, 29, 26)
                                                              addLabelWidth:YES
                                                                      image:[UIImage imageNamed:@"ButtonPerformer.png"]
                                                               imagePressed:[UIImage imageNamed:@" ButtonPerformer.png"]
                                                               leftCapWidth:13.0f
                                                              darkTextColor:YES]];
    }
    performersView.buttons = performerButtons;
}

@end
