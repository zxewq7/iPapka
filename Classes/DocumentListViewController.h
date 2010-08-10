//
//  MeesterViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"

@class SwitchViewController;

@interface DocumentListViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource> 
{
    AQGridView           *docListView;
    NSMutableArray       *_documents;
    SwitchViewController *switchViewController;
}

@property (nonatomic, retain) IBOutlet AQGridView           *docListView;
@property (nonatomic, retain) SwitchViewController *switchViewController;
@end

