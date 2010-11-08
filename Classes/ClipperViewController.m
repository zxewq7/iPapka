//
//  ClipperViewController.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 10.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ClipperViewController.h"
#import "Logger.h"

@implementation ClipperViewController
@synthesize opened;

- (void) setOpened:(BOOL)anOpened
{
    opened = anOpened;
    ((UIImageView *)self.view).image = [UIImage imageNamed:opened?@"ClipperOpened.png":@"ClipperClosed.png"];
}

- (void)loadView
{
    UIView *v = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"ClipperClosed.png"]];
    
    self.view = v;
    
    [v release];
    
    self.view.userInteractionEnabled = NO;
}

- (void) counfigureTapzones
{
    CGRect viewFrame = self.view.frame;
    
    CGRect tapZoneRect1 = CGRectMake(viewFrame.origin.x + 147.0f, viewFrame.origin.y, 93.0f, 35.0f);
    UIView *tapZone1 = [[UIView alloc] initWithFrame: tapZoneRect1];
    tapZone1.backgroundColor = [UIColor clearColor];
    tapZone1.autoresizingMask = self.view.autoresizingMask;
    
    tapZone1.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openClipperTap:)];
    tapRecognizer1.numberOfTapsRequired = 1;
    tapRecognizer1.delegate = self;

    //show log
    UITapGestureRecognizer *tapRecognizerLog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openLogTap:)];
    tapRecognizerLog.numberOfTapsRequired = 3;
    tapRecognizerLog.delegate = self;
    
    [tapZone1 addGestureRecognizer: tapRecognizerLog];
    [tapRecognizerLog release];

    
    [tapZone1 addGestureRecognizer: tapRecognizer1];
    [tapRecognizer1 release];
    
    [self.view.superview addSubview: tapZone1];
    [self.view.superview bringSubviewToFront: tapZone1];
    
    [tapZone1 release];

    CGRect tapZoneRect2 = CGRectMake(viewFrame.origin.x + 43.0f, viewFrame.origin.y + 35.0f, 299.0f, 85.0f);
    UIView *tapZone2 = [[UIView alloc] initWithFrame: tapZoneRect2];
    tapZone2.backgroundColor = [UIColor clearColor];
    tapZone2.autoresizingMask = self.view.autoresizingMask;
    
    tapZone2.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openClipperTap:)];
    tapRecognizer2.numberOfTapsRequired = 1;
    tapRecognizer2.delegate = self;
    
    [tapZone2 addGestureRecognizer: tapRecognizer2];
    [tapRecognizer2 release];

    [self.view.superview addSubview: tapZone2];
    [self.view.superview bringSubviewToFront: tapZone2];
    
    [tapZone2 release];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}


- (void)dealloc 
{
    [super dealloc];
}

- (void) silentClose
{
    opened = NO;
    ((UIImageView *)self.view).image = [UIImage imageNamed:opened?@"ClipperOpened.png":@"ClipperClosed.png"];
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

-(void) openClipperTap:(UIGestureRecognizer *)gestureRecognizer
{
    self.opened = !self.opened;
}

-(void) openLogTap:(UIGestureRecognizer *)gestureRecognizer
{
    [[Logger sharedLogger] showLogForController:self];
}
@end
