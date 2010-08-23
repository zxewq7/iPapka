//
//  FoldersViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 18.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FoldersViewController.h"
#import "RootViewController.h"
#import "DocumentViewController.h"
#import "Folder.h"
#import "TDBadgedCell.h"

@implementation FoldersViewController
@synthesize rootViewController, folders;

#pragma mark -
#pragma mark initialization

- (void)awakeFromNib
{	
    self.title = NSLocalizedString(@"Folders", "Folders");
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *foldersData = [currentDefaults objectForKey:@"folders"];
    if (foldersData != nil)
        self.folders = [NSKeyedUnarchiver unarchiveObjectWithData:foldersData];
    
    [super viewDidLoad];
}

-(void) viewDidUnload {
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.folders count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FoldersViewControllerCellIdentifier";
    
    TDBadgedCell *cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	

    Folder *folder = [self.folders objectAtIndex:indexPath.row];
    
	cell.textLabel.text = folder.localizedName;
	cell.badgeNumber = folder.countUnread; 
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Folder *folder = [self.folders objectAtIndex:indexPath.row];
    self.rootViewController.folder = folder;
    [self.navigationController pushViewController:self.rootViewController animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    self.rootViewController = nil;
    self.folders = nil;
    [super dealloc];
}
@end
