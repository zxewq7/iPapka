//
//  AttachmetsViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQGridView.h"

@class Document;
@interface AttachmentsViewController : NSObject<AQGridViewDelegate, AQGridViewDataSource> {
    AQGridView           *attachmentListView;
    Document             *_document;
}
@property (nonatomic, retain) IBOutlet AQGridView *attachmentListView;
@property (nonatomic, retain) Document             *document;
@end
