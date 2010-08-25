//
//  DocumentInfoViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged, Document;
@interface DocumentInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    DocumentManaged *document;
    Document        *unmanagedDocument;
    UITableView     *tableView;
    UILabel         *documentTitle;
    BOOL            isResolution;
    BOOL            hasParentResolution;
    NSMutableArray  *sections;
    NSDateFormatter *dateFormatter;
}
@property (nonatomic, retain, setter=setDocument:) DocumentManaged  *document;
@end
