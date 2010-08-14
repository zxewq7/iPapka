//
//  DocumentsGridController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQGridView.h"

@interface DocumentsGridDatasource : UIViewController <AQGridViewDataSource>
{
    AQGridView           *docListView;
    NSMutableArray       *allDocuments;
    NSArray              *sortDescriptors;
    
}
@property (nonatomic, retain) IBOutlet AQGridView  *docListView;
@property (nonatomic, retain) NSMutableArray       *allDocuments;
@property (nonatomic, retain) NSArray              *sortDescriptors;
@end
