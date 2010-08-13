//
//  MeesterViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"

@class SwitchViewController, LNDataSource;

@interface DocumentListViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource> 
{
    AQGridView           *docListView;
    LNDataSource         *_dataController;
    SwitchViewController *switchViewController;
    NSMutableArray              *allDocuments;
    NSArray              *sortDescriptors;
}

@property (nonatomic, retain) IBOutlet AQGridView  *docListView;
@property (nonatomic, retain) SwitchViewController *switchViewController;
@property (nonatomic, retain) NSMutableArray              *allDocuments;
@property (nonatomic, retain) NSArray              *sortDescriptors;
@end

