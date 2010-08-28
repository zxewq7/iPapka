    //
//  DocumentLinkViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 28.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentLinkViewController.h"

@interface DocumentLinkViewController(Private)
-(void) createToolbar;
@end

@implementation DocumentLinkViewController

- (void)loadView
{
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,180)];
    
    self.view = v;
    
    [v release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocumentViewBackground.png"]];
    self.view.backgroundColor = backgroundColor;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}




- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}


@end
