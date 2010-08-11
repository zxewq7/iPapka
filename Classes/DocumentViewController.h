//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"

@class SwitchViewController, LNDataSource, Document;

@interface DocumentViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource> 
{
    AQGridView           *docListView;
    LNDataSource         *_dataController;
    SwitchViewController *switchViewController;
    Document             *_document;
    UILabel              *documentTitle;
}
@property (nonatomic, retain) SwitchViewController *switchViewController;
@property (nonatomic, retain) Document             *document;
@property (nonatomic, retain) IBOutlet AQGridView  *docListView;
@property (nonatomic, retain) IBOutlet UILabel     *documentTitle;
- (void) showDocumentList:(id) sender;
@end
