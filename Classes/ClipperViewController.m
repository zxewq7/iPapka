//
//  ClipperViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ClipperViewController.h"


@implementation ClipperViewController

- (void)loadView
{
    UIView *v = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"ClipperClosed.png"]];
    
    self.view = v;
    
    [v release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)dealloc {
    [super dealloc];
}

- (CGFloat) contentOffset
{
    return 42.0f;
}
@end
