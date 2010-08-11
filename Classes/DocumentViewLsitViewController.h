//
//  DocumentViewLsitViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"

@class LNDataSource;
@interface DocumentViewLsitViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource> 
{
    AQGridView           *docListView;
    LNDataSource         *_dataController;
}

@property (nonatomic, retain) IBOutlet AQGridView *docListView;
@end