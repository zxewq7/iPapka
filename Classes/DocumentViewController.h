//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentsGridDatasource.h"

@class SwitchViewController, Document, AttachmentsViewController;

@interface DocumentViewController : DocumentsGridDatasource<AQGridViewDelegate>
{
    SwitchViewController        *switchViewController;
    Document                    *_document;
    UILabel                     *documentTitle;
    AttachmentsViewController   *attachmentsViewController;
}
@property (nonatomic, retain) SwitchViewController                  *switchViewController;
@property (nonatomic, retain) Document                              *document;
@property (nonatomic, retain) IBOutlet UILabel                      *documentTitle;
@property (nonatomic, retain) IBOutlet AttachmentsViewController    *attachmentsViewController;
- (void) showDocumentList:(id) sender;
@end
