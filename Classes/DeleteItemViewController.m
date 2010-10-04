    //
//  DeleteItemViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 04.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DeleteItemViewController.h"
#import "SynthesizeSingleton.h"


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
    
    [popoverController presentPopoverFromRect: targetView.frame inView:[targetView superview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


- (void)viewDidLoad 
{
    self.contentSizeForViewInPopover = CGSizeMake(200,40);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Delete", "Delete") forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(0, 0, self.contentSizeForViewInPopover.width, self.contentSizeForViewInPopover.height);
    [button addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
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
