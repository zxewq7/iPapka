//
//  MeesterViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentsGridDatasource.h"

@class SwitchViewController;

@interface DocumentListViewController : DocumentsGridDatasource<AQGridViewDelegate> 
{
    SwitchViewController *switchViewController;
}

@property (nonatomic, retain) SwitchViewController *switchViewController;
@end

