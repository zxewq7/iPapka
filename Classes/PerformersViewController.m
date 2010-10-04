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
#import "DocumentResolution.h"
#import "Person.h"
#import "PersonPickerViewController.h"
#import "DataSource.h"

@interface PerformersViewController (Private)
- (void) updateContent;
@end

@implementation PerformersViewController
@synthesize document;

-(void) setDocument:(DocumentResolution *) aDocument
{
    if (document == aDocument)
        return;

    [document release];
    
    document = [aDocument retain];
    
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
    
    UIButton *buttonAdd = [UIButton imageButton:self
                                       selector:@selector(pickPerformer:)
                                          image:[UIImage imageNamed: @"ButtonAdd.png"]
                                  imageSelected:[UIImage imageNamed: @"ButtonAdd.png"]];
    
    CGRect buttonAddFrame = buttonAdd.frame;
    buttonAddFrame.origin.y = 0;
    buttonAddFrame.origin.x = viewSize.width - buttonAddFrame.size.width - 5;
    buttonAdd.frame = buttonAddFrame;
    
    buttonAdd.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin);
    [self.view addSubview: buttonAdd];
    
    performersView = [[ViewWithButtons alloc] initWithFrame: CGRectMake(0, 0, viewSize.width - buttonAddFrame.size.width - 5, viewSize.height)];
    
    performersView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    performersView.spaceBetweenButtons = 5.0f;
    performersView.spaceBetweenRows = 5.0f;
    
    performersView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview: performersView];
}

#pragma mark -
#pragma mark actions
-(void) pickPerformer:(id) sender
{
    if (!personPickerViewController)
    {
        personPickerViewController = [[PersonPickerViewController alloc] init];
        personPickerViewController.target = self;
        personPickerViewController.selector = @selector(setPerformer:);
    }
    
    if (!popoverController)
        popoverController = [[UIPopoverController alloc] initWithContentViewController: personPickerViewController];
    
    UIView *button = (UIView *)sender;
    CGRect targetRect = button.bounds;
	[popoverController presentPopoverFromRect: targetRect inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void) setPerformer:(id) sender
{
    [popoverController dismissPopoverAnimated:YES];

    Person *p = personPickerViewController.person;
    if (p)
    {
        [document addPerformersObject: p];
        [[DataSource sharedDataSource] commit];
        [self updateContent];
        
    }
}

#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    [super viewDidUnload];

    [performersView release];
    performersView = nil;

    [sortByLastDescriptors release];
    sortByLastDescriptors = nil;
    
    [popoverController release];
    personPickerViewController = nil;
}


- (void)dealloc 
{
    self.document = nil;

    [performers release]; performers = nil;

    [performersView release]; performersView = nil;

    [sortByLastDescriptors release]; sortByLastDescriptors = nil;

    [popoverController release]; personPickerViewController = nil;

    [super dealloc];
}

#pragma Private

- (void) updateContent
{
    [performers release];

    if (document)
    {
        NSSet *ps = document.performers;
        performers = [[NSMutableArray alloc] initWithCapacity:[ps count]];
        for (Person *p in ps)
            [performers addObject: p];
        
        [performers sortUsingDescriptors: sortByLastDescriptors];
    }
    else
        performers = nil;

    NSMutableArray *performerButtons = [NSMutableArray arrayWithCapacity: [performers count]];
    
    for (Person *performer in performers)
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
