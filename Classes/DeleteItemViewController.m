    //
//  DeleteItemViewController.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 04.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DeleteItemViewController.h"
#import "SynthesizeSingleton.h"
#import "UIButton+Additions.h"

@implementation DeleteItemViewController
SYNTHESIZE_SINGLETON_FOR_CLASS(DeleteItemViewController);

- (void) showForView:(UIView *) aView handler:(void (^)(UIView *target))aHandler;
{
    if (handler != aHandler)
    {
        [handler release];
        handler = [aHandler copy];
    }
    
    if (targetView != aView)
    {
        [targetView release];
        targetView = [aView retain];
    }
    
    if (!popoverController)
        popoverController = [[UIPopoverController alloc] initWithContentViewController: self];
    
    [popoverController presentPopoverFromRect: targetView.bounds inView:targetView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


- (void)viewDidLoad 
{
    self.contentSizeForViewInPopover = CGSizeMake(200,40);
    UIButton *button = [UIButton buttonWithBackgroundAndTitle:NSLocalizedString(@"Delete", "Delete")
                                                    titleFont:[UIFont boldSystemFontOfSize:14]
                                                       target:self
                                                     selector:@selector(remove:)
                                                        frame:CGRectMake(0, 0, self.contentSizeForViewInPopover.width, self.contentSizeForViewInPopover.height)
                                                addLabelWidth:NO
                                                        image:[UIImage imageNamed:@"ButtonRed.png"]
                                                 imagePressed:[UIImage imageNamed:@"ButtonRed.png"]
                                                 leftCapWidth:12.0
                                                darkTextColor:NO];

    [button setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);

    [popoverController dismissPopoverAnimated:YES];
    
    [self.view addSubview:button];
    [super viewDidLoad];
}

-(void) remove:(id) sender
{
    [popoverController dismissPopoverAnimated:YES];
    if (handler)
        handler(targetView);

    [handler release]; handler = nil;
    [targetView release]; targetView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}


- (void)viewDidUnload 
{
    [super viewDidUnload];
    [popoverController release]; popoverController = nil;
}


- (void)dealloc 
{
    [popoverController release]; popoverController = nil;
    [targetView release]; targetView = nil;
    [handler release]; handler = nil;
    [super dealloc];
}


@end
