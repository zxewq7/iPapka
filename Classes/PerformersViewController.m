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
#import "DocumentResolutionAbstract.h"
#import "DocumentResolutionParent.h"
#import "Person.h"
#import "PersonPickerViewController.h"
#import "DataSource.h"
#import "DeleteItemViewController.h"
#import "PerformersEditorController.h"

@interface PerformersViewController (Private)
- (void) updateContent;
@end

@implementation PerformersViewController
@synthesize document;

-(void) setDocument:(DocumentResolutionAbstract *) aDocument
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
    
    CGSize viewSize = self.view.bounds.size;
    
    editToolbar = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIButton *buttonAdd = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    [buttonAdd addTarget:self action:@selector(addPerformer:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect buttonAddFrame = buttonAdd.frame;
    buttonAddFrame.origin.y = 0;
    buttonAddFrame.origin.x = 0;
    buttonAdd.frame = buttonAddFrame;
    
    [editToolbar addSubview:buttonAdd];
    
    UIButton *buttonReorder = [UIButton imageButton:self
                                           selector:@selector(reorderPerformers:)
                                              image:[UIImage imageNamed:@"ButtonReorder.png"]
                                      imageSelected:[UIImage imageNamed:@"ButtonReorder.png"]];
    
    CGRect buttonReorderFrame = buttonReorder.frame;
    buttonReorderFrame.origin.y = buttonAddFrame.origin.y + buttonAddFrame.size.height + 5.0f;
    buttonReorderFrame.origin.x = 0;
    buttonReorder.frame = buttonReorderFrame;
    
    [editToolbar addSubview:buttonReorder];
    
    editToolbar.frame = CGRectMake(viewSize.width - MAX(buttonReorderFrame.size.width, buttonAddFrame.size.width) - 5.f, 
                                   0, 
                                   MAX(buttonReorderFrame.size.width, buttonAddFrame.size.width),
                                   buttonReorderFrame.origin.y + buttonReorderFrame.size.height);
    
    editToolbar.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin);
    
    [self.view addSubview: editToolbar];
    
    performersView = [[ViewWithButtons alloc] initWithFrame: CGRectMake(0, 0, viewSize.width - buttonAddFrame.size.width - 5.0f, 200)];
    
    performersView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    performersView.spaceBetweenButtons = 5.0f;
    performersView.spaceBetweenRows = 5.0f;
    performersView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    [self.view addSubview: performersView];
}

#pragma mark -
#pragma mark actions
-(void) addPerformer:(id) sender
{
    if (!personPopoverController)
    {
        PersonPickerViewController *picker = [[PersonPickerViewController alloc] init];
        picker.target = self;
        picker.action = @selector(setPerformer:);
        personPopoverController = [[UIPopoverController alloc] initWithContentViewController: picker];
        [picker release];
    }
    
    UIView *button = (UIView *)sender;
	[personPopoverController presentPopoverFromRect: button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

-(void) removePerformer:(id) sender
{
    __block PerformersViewController *blockSelf = self;

    DocumentResolution *resolution = (DocumentResolution *) document;
    
    [[DeleteItemViewController sharedDeleteItemViewController] showForView:(UIView *)sender handler:^(UIView *target){
        Person *performerToDelete  = [performers objectAtIndex:target.tag];
        [resolution removePerformersObject:performerToDelete];
        [[DataSource sharedDataSource] commit];
        [blockSelf updateContent];
    }];
}


-(void) setPerformer:(id) sender
{
    [personPopoverController dismissPopoverAnimated:YES];

    DocumentResolution *resolution = (DocumentResolution *) document;
    
    Person *p = ((PersonPickerViewController *)sender).person;
    if (p)
    {
        [resolution addPerformersObject: p];
        [[DataSource sharedDataSource] commit];
        [self updateContent];
        
    }
}

-(void) reorderPerformers:(id) sender
{
    if (!personReorderPopoverController)
    {
        PerformersEditorController *picker = [[PerformersEditorController alloc] init];
        picker.target = self;
        picker.action = @selector(setReorderedPerformers:);
        
        personReorderPopoverController = [[UIPopoverController alloc] initWithContentViewController: picker];
        [picker release];
    }

    PerformersEditorController *picker = (PerformersEditorController *)personReorderPopoverController.contentViewController;
    
    picker.document = (DocumentResolution *)self.document;

    UIView *button = (UIView *)sender;
	[personReorderPopoverController presentPopoverFromRect: button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

-(void) setReorderedPerformers:(id) sender
{
    [[DataSource sharedDataSource] commit];
    [self updateContent];
}
#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload 
{
    [super viewDidUnload];

    [performersView release]; performersView = nil;

    [personPopoverController release]; personPopoverController = nil;
    
    [personReorderPopoverController release]; personReorderPopoverController = nil;
    
    [editToolbar release]; editToolbar = nil;
}


- (void)dealloc 
{
    self.document = nil;

    [performers release]; performers = nil;

    [performersView release]; performersView = nil;

    [personPopoverController release]; personPopoverController = nil;
    
    [editToolbar release]; editToolbar = nil;

    [personReorderPopoverController release]; personReorderPopoverController = nil;
    
    [super dealloc];
}

#pragma Private

- (void) updateContent
{
    [performers release];
    performers = nil;
    NSMutableArray *performerButtons = nil;

    BOOL wasHidden = editToolbar.hidden;
    
    editToolbar.hidden = !document.isEditable;
    
    //hide or show add performer button
    if (wasHidden != editToolbar.hidden)
    {
        CGRect frame = performersView.frame;
        if (editToolbar.hidden)
        {
            frame.size.width += editToolbar.frame.size.width;
            performersView.frame = frame;
        }
        else
        {
            frame.size.width -= editToolbar.frame.size.width;
            performersView.frame = frame;
        }
    }
    
    if (document)
    {
        UIFont *font = [UIFont fontWithName:@"CharterC" size:16];
        
        if ([document isKindOfClass:[DocumentResolution class]])
        {
            performers = ((DocumentResolution *)document).performersOrdered;

            [performers retain];
            
            NSUInteger countPerformers = [performers count];
            
            performerButtons = [NSMutableArray arrayWithCapacity: countPerformers];

            UIImage *buttonBackground = [UIImage imageNamed:@"ButtonPerformer.png"];
            
            for (NSUInteger i=0; i < countPerformers; i++)
            {
                Person *performer = [performers objectAtIndex:i];
                
                UIButton *performerButton = [UIButton buttonWithBackgroundAndTitle:performer.fullName
                                                                         titleFont:font
                                                                            target:self
                                                                          selector:(document.isEditable?@selector(removePerformer:):nil)
                                                                             frame:CGRectMake(0, 0, 29, 26)
                                                                     addLabelWidth:YES
                                                                             image:buttonBackground
                                                                      imagePressed:buttonBackground
                                                                      leftCapWidth:13.0f
                                                                     darkTextColor:YES];

                performerButton.tag = i;
                [performerButtons addObject: performerButton];
            }
        }
        else if ([document isKindOfClass:[DocumentResolutionParent class]])
        {
            performers = [NSMutableArray arrayWithArray: ((DocumentResolutionParent *)document).performers];
            [performers retain];
            
            NSUInteger countPerformers = [performers count];
            
            performerButtons = [NSMutableArray arrayWithCapacity: countPerformers];
            
            UIColor *color = [UIColor clearColor];
            
            for (NSUInteger i=0; i < countPerformers; i++)
            {
                 NSString *performer = [performers objectAtIndex:i];
                
                UILabel *performerButton = [[UILabel alloc] initWithFrame:CGRectZero];
                performerButton.backgroundColor = color;
                performerButton.font = font;
                performerButton.text = performer;
                [performerButton sizeToFit];
                performerButton.tag = i;
                
                [performerButtons addObject: performerButton];
                
                [performerButton release];
            }
            
        }
    }

    performersView.subviews = performerButtons;
    
    //resize content
    [performersView sizeToFit];
    
    //fix performersView position
    CGRect performersViewFrame = performersView.frame;
    performersViewFrame.origin.y = 0;
    performersViewFrame.origin.x = 0;
    performersView.frame = performersViewFrame;
    
    //fix view size
    CGRect viewFrame = self.view.frame;

    viewFrame.size.height = MAX(performersViewFrame.size.height, editToolbar.frame.origin.y + editToolbar.frame.size.height);
    
    self.view.frame = viewFrame;
    
    [self.view.superview setNeedsLayout];
}
@end
