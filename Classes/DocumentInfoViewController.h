//
//  DocumentInfoViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Document, Attachment, DocumentInfoDetailsView;
@interface DocumentInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    Document    *document;
    DocumentInfoDetailsView  *documentInfo;
    UISegmentedControl *filter;
    NSDateFormatter    *dateFormatter;
    NSArray            *currentItems;
    NSUInteger         attachmentIndex;
    NSUInteger         linkIndex;
    UITableView        *tableView;
}
@property (nonatomic, retain, setter=setDocument:) Document   *document;
@property (nonatomic, retain)                      Attachment *attachment;
@property (nonatomic, retain)                      Document   *link;

@end
