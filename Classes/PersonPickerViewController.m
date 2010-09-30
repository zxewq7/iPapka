//
//  PersonPickerViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 18.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PersonPickerViewController.h"
#import "Person.h"
#import "DataSource.h"

@implementation PersonPickerViewController
@synthesize person, selector, target;
#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    persons = [[DataSource sharedDataSource] persons];
    [persons retain];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [persons count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PersonCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Person *p = [persons objectAtIndex: indexPath.row];
    cell.textLabel.text = p.fullName;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    person = [persons objectAtIndex: indexPath.row];
    if( [target respondsToSelector:selector] )
        [target performSelector:selector withObject:self];    
}


#pragma mark -
#pragma mark Memory management
- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    [persons release];
    persons = nil;
}


- (void)dealloc 
{
    [persons release];
    persons = nil;
    
    self.person = nil;
    
    self.target = nil;
    
    self.selector = nil;

    [super dealloc];
}
@end

