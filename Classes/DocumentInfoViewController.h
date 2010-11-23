//
//  DocumentInfoViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentWithResources, Attachment, DocumentInfoView, DocumentLink;
@interface DocumentInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    DocumentWithResources       *document;
    DocumentInfoView   *documentInfo;
    UISegmentedControl *filter;
    NSDateFormatter    *dateFormatter;
    NSArray            *currentItems;
    NSUInteger         attachmentIndex;
    NSUInteger         linkIndex;
    UITableView        *tableView;
    UILabel            *titleLabel;
    DocumentLink       *link;
}
@property (nonatomic, retain, setter=setDocument:) DocumentWithResources   *document;
@property (nonatomic, retain)                      Attachment *attachment;
@property (nonatomic, retain)                      DocumentLink   *link;

@end
