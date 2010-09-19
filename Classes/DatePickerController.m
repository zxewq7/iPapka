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
    self.contentSizeForViewInPopover = CGSizeMake(300,300);
                          
    datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	datePickerView.datePickerMode = UIDatePickerModeDate;
    datePickerView.maximumDate = maximumDate;
	
        // note we are using CGRectZero for the dimensions of our picker view,
        // this is because picker views have a built in optimum size,
        // you just need to set the correct origin in your view.
        //
        // position the picker at the bottom
    datePickerView.frame = CGRectMake(-150, 0, 300, 300);
    if  (date)
        datePickerView.date = date;

    [self.view addSubview:datePickerView];
    [datePickerView addTarget:self action:@selector(done:) forControlEvents:UIControlEventValueChanged];

 }

#pragma mark -
#pragma mark actions

-(void) done:(id) sender
{
    self.date = datePickerView.date;
    if( [target respondsToSelector:selector] )
        [target performSelector:selector withObject:self];
}

#pragma mark -
#pragma Memory management

- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    [datePickerView release];
    datePickerView = nil;
}

- (void)dealloc {
    [datePickerView release];
    self.date = nil;
    self.maximumDate = nil;
    self.target = nil;
    self.selector = nil;
    [super dealloc];
}


@end
