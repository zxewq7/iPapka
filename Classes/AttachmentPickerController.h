//
//  AttachmentPickerController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 03.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Document, Attachment;
@interface AttachmentPickerController : UITableViewController 
{
    UITableView *tableView;
    Document *document;
    Attachment *attachment;
}

@property (nonatomic, retain) Document *document;
@property (nonatomic, retain) Attachment *attachment;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) id target;
@end
