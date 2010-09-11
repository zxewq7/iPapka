//
//  DocumentInfoViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 25.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged, Document, Attachment;
@interface DocumentInfoViewController : UITableViewController
{
    DocumentManaged *document;
    Document        *unmanagedDocument;
    UILabel         *documentTitle;
    UILabel         *documentDetails;
    UISegmentedControl *filter;
    NSDateFormatter *dateFormatter;
    NSArray         *currentItems;
    Attachment      *attachment;
}
@property (nonatomic, retain, setter=setDocument:) DocumentManaged  *document;
@property (nonatomic, retain)                      Attachment       *attachment;

@end
