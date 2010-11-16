//
//  PerformersViewController.m
//  iPapka
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

@interface PerformersViewController (Private)
- (void) updateContent;
@end

@implementation PerformersViewController
@synthesize document;

-(void) setDocument:(DocumentResolutionAbstract *) aDocument
{
    if (document != aDocument)
    {
        [document release];
        document = [aDocument retain];
    }
    
    [self updateContent];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    CGSize viewSize = self.view.bounds.size;
    
    buttonAdd = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    [buttonAdd addTarget:self action:@selector(editPerformers:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect buttonAddFrame = buttonAdd.frame;
    buttonAddFrame.origin.x = viewSize.width - buttonAddFrame.size.width;
    buttonAddFrame.origin.y = 0;
    buttonAdd.frame = buttonAddFrame;

    buttonAdd.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin);

    [self.view addSubview:buttonAdd];
    
    performersView = [[ViewWithButtons alloc] initWithFrame: CGRectMake(0, 0, viewSize.width - buttonAdd.frame.size.width - 5.0f, 200)];
    
    performersView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    performersView.spaceBetweenButtons = 5.0f;
    performersView.spaceBetweenRows = 5.0f;
    performersView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    [self.view addSubview: performersView];
}

#pragma mark -
#pragma mark actions
-(void) editPerformers:(id) sender
{
    if (!personPopoverController)
    {
        PersonPickerViewController *picker = [[PersonPickerViewController alloc] init];
        picker.target = self;
        picker.action = @selector(performersEdited:);
        personPopoverController = [[UIPopoverController alloc] initWithContentViewController: picker];
        [picker release];
    }
    
    PersonPickerViewController *picker = (PersonPickerViewController *)personPopoverController.contentViewController;
    
    picker.persons = ((DocumentResolution *)self.document).performersOrdered;

    
    UIView *button = (UIView *)sender;
	[personPopoverController presentPopoverFromRect: button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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

-(void) performersEdited:(id) sender
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
    
    [buttonAdd release]; buttonAdd = nil;
}


- (void)dealloc 
{
    self.document = nil;

    [performers release]; performers = nil;

    [performersView release]; performersView = nil;

    [personPopoverController release]; personPopoverController = nil;
    
    [buttonAdd release]; buttonAdd = nil;

    [super dealloc];
}

#pragma Private

- (void) updateContent
{
    [performers release];
    performers = nil;
    NSMutableArray *performerButtons = nil;

    BOOL wasHidden = buttonAdd.hidden;
    
    buttonAdd.hidden = !document.isEditable;
    
    //hide or show add performer button
    if (wasHidden != buttonAdd.hidden)
    {
        CGRect frame = performersView.frame;
        if (buttonAdd.hidden)
        {
            frame.size.width += buttonAdd.frame.size.width;
            performersView.frame = frame;
        }
        else
        {
            frame.size.width -= buttonAdd.frame.size.width;
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

    viewFrame.size.height = MAX(performersViewFrame.size.height, buttonAdd.frame.origin.y + buttonAdd.frame.size.height);
    
    self.view.frame = viewFrame;
    
    [self.view.superview setNeedsLayout];
}
@end
