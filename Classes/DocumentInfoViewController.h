//
//  DocumentInfoViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged;
@interface DocumentInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    DocumentManaged    *document;
    UILabel            *documentTitle;
    UILabel            *documentDetails;
    UISegmentedControl *filter;
    NSDateFormatter    *dateFormatter;
    NSArray            *currentItems;
    NSUInteger         attachmentIndex;
    NSUInteger         linkIndex;
    UITableView        *tableView;
}
@property (nonatomic, retain, setter=setDocument:) DocumentManaged  *document;
@property (nonatomic, assign)                      NSUInteger       attachmentIndex;
@property (nonatomic, assign)                      NSUInteger       linkIndex;

@end
