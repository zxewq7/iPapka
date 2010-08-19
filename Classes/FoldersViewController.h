//
//  FoldersViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 18.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MasterViewController.h"

@class RootViewController, Folder;

@interface FoldersViewController : MasterViewController <UISplitViewControllerDelegate> {
    RootViewController *rootViewController;
    NSArray            *folders;
}
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) NSArray *folders;
@end
