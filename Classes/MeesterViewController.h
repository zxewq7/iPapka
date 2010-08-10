//
//  MeesterViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "DocumentCellChooser.h"

@interface MeesterViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource, DocumentCellChooserDelegate> 
{
    AQGridView *_docListView;
    NSMutableArray    *_documents;
    
}

@property (nonatomic, retain) IBOutlet AQGridView * docListView;
@end

