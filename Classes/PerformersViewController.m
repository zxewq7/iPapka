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
#import "DeleteItemViewController.h"

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
    
    UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    [buttonAdd addTarget:self action:@selector(addPerformer:) forControlEvents:UIControlEventTouchUpInside];
    
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
-(void) addPerformer:(id) sender
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

-(void) removePerformer:(id) sender
{
    __block PerformersViewController *blockSelf = self;

    [[DeleteItemViewController sharedDeleteItemViewController] showForView:(UIView *)sender handler:^(UIView *target){
        Person *performerToDelete  = [performers objectAtIndex:target.tag];
        [document removePerformersObject:performerToDelete];
        [[DataSource sharedDataSource] commit];
        [blockSelf updateContent];
    }];
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
    
    NSUInteger countPerformers = [performers count];
    for (NSUInteger i=0; i < countPerformers; i++)
    {
        Person *performer = [performers objectAtIndex:i];
        
        UIButton *performerButton = [UIButton buttonWithBackgroundAndTitle:performer.fullName
                                                                 titleFont:[UIFont fontWithName:@"CharterC" size:16]
                                                                    target:self
                                                                  selector:@selector(removePerformer:)
                                                                     frame:CGRectMake(0, 0, 29, 26)
                                                             addLabelWidth:YES
                                                                     image:[UIImage imageNamed:@"ButtonPerformer.png"]
                                                              imagePressed:[UIImage imageNamed:@" ButtonPerformer.png"]
                                                              leftCapWidth:13.0f
                                                             darkTextColor:YES];
        performerButton.tag = i;
        [performerButtons addObject: performerButton];
    }
    performersView.buttons = performerButtons;
}

@end
