//
//  DocumentInfoViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Document, AttachmentManaged;
@interface DocumentInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    Document    *document;
    UILabel            *documentTitle;
    UILabel            *documentDetails;
    UISegmentedControl *filter;
    NSDateFormatter    *dateFormatter;
    NSArray            *currentItems;
    NSUInteger         attachmentIndex;
    NSUInteger         linkIndex;
    UITableView        *tableView;
}
@property (nonatomic, retain, setter=setDocument:) Document   *document;
@property (nonatomic, retain)                      AttachmentManaged *attachment;
@property (nonatomic, retain)                      Document   *link;

@end
