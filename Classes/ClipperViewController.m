//
//  ClipperViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ClipperViewController.h"


@implementation ClipperViewController
@synthesize opened;

- (void) setOpened:(BOOL)anOpened
{
    opened = anOpened;
    ((UIImageView *)self.view).image = [UIImage imageNamed:opened?@"ClipperOpened.png":@"ClipperClosed.png"];
}

- (void)loadView
{
    UIView *v = [[UIImageView alloc] initWithImage: [UIImage imageNamed:opened?@"ClipperOpened.png":@"ClipperClosed.png"]];
    
    self.view = v;
    
    [v release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;
    self.view.userInteractionEnabled = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [tapRecognizer release];
    tapRecognizer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)dealloc 
{
    [tapRecognizer release];
    [super dealloc];
}

- (CGFloat) contentOffset
{
    return 42.0f;
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

-(void) handleTapFrom:(UITouch *)touch
{
    self.opened = !self.opened;
}
@end
