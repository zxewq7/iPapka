    //
//  SwitchViewController.m
//  MultiViewiPad
//
//  Created by Chakra on 07/05/10.
//  Copyright 2010 Chakra Interactive Pvt Ltd. All rights reserved.
//

#import "SwitchViewController.h"
#import "DocumentListViewController.h"
#import "DocumentViewController.h"


@implementation SwitchViewController

@synthesize documentListViewController, documentViewController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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
- (void)viewDidLoad {
	
	[self listDocuments];  
	
    [super viewDidLoad];
}

- (void) listDocuments
{
    if (self.documentListViewController == nil)
    {
        DocumentListViewController *tmpView = [[DocumentListViewController alloc] initWithNibName:@"DocumentListViewController" bundle:nil];
        tmpView.switchViewController = self;
        self.documentListViewController = tmpView;
        [tmpView release];  
    }
    if (self.documentListViewController.view.superview != nil)
        return;
    [currentView.view removeFromSuperview];
    currentView = self.documentListViewController;
    [self.view insertSubview:self.documentListViewController.view atIndex:0];

}
- (void) showDocument:(Document *) anDocument;
{
    if (self.documentViewController == nil)
    {
        DocumentViewController *tmpView = [[DocumentViewController alloc] initWithNibName:@"DocumentViewController" bundle:nil];
        tmpView.switchViewController = self;
        self.documentViewController = tmpView;
        [tmpView release];  
    }
    if (self.documentViewController.view.superview != nil)
        return;
    [currentView.view removeFromSuperview];
    self.documentViewController.document = anDocument;
    [self.view insertSubview:self.documentViewController.view atIndex:0];
    currentView = self.documentViewController;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.documentViewController = nil;
	self.documentListViewController = nil;
    [super dealloc];
}


@end
