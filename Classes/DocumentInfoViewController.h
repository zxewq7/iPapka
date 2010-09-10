//
//  DocumentInfoViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged, Document, DatePickerController;
@interface DocumentInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UINavigationController       *navigationController;
    DocumentManaged *document;
    Document        *unmanagedDocument;
    UITableView     *tableView;
    UILabel         *documentTitle;
    UILabel         *documentDetails;
    UISegmentedControl *filter;
    BOOL            isResolution;
    BOOL            hasParentResolution;
    NSMutableArray  *sections;
    NSDateFormatter *dateFormatter;
    CGFloat         cellWidth;
    DatePickerController *datePickerController;
    UIPopoverController  *popoverController;
    UIButton        *deadlineButton;
}
@property (nonatomic, retain, setter=setDocument:) DocumentManaged  *document;
@property (nonatomic, retain) IBOutlet UINavigationController       *navigationController;
@end
