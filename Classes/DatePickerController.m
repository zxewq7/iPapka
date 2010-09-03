//
//  DatePickerController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 03.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DatePickerController.h"


@implementation DatePickerController
@synthesize date, maximumDate, selector, target;

-(void) loadView
{
    self.view = [[UIView alloc] init];
}

 - (void)viewDidLoad 
{
 [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(300,300+44);
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target: self action: @selector(cancel:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target: self action: @selector(done:)];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolbar.items = [NSArray arrayWithObjects:cancelButton, 
                                              flexBarButton,
                                              doneButton,
                                              nil];
    [cancelButton release];
    [doneButton release];
    [flexBarButton release];
    
    [self.view addSubview:toolbar];
    
    [toolbar release];
                          
    datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	datePickerView.datePickerMode = UIDatePickerModeDate;
    datePickerView.maximumDate = maximumDate;
	
        // note we are using CGRectZero for the dimensions of our picker view,
        // this is because picker views have a built in optimum size,
        // you just need to set the correct origin in your view.
        //
        // position the picker at the bottom
    datePickerView.frame = CGRectMake(-150, 44, 300, 300);
    if  (date)
        datePickerView.date = date;

    [self.view addSubview:datePickerView];
 }

- (void)viewDidUnload {
    [super viewDidUnload];
    [datePickerView release];
    datePickerView = nil;
        // Release any retained subviews of the main view.
        // e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark actions

-(void) cancel:(id) sender
{
    self.date = nil;
    if( [target respondsToSelector:selector] )
        [target performSelector:selector withObject:self];
}

-(void) done:(id) sender
{
    self.date = datePickerView.date;
    if( [target respondsToSelector:selector] )
        [target performSelector:selector withObject:self];
}

- (void)dealloc {
    [datePickerView release];
    self.date = nil;
    self.maximumDate = nil;
    self.target = nil;
    [super dealloc];
}


@end
