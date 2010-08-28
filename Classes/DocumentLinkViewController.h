//
//  DocumentLinkViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 28.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged, Attachment, Document, AttachmentsViewController;

@interface DocumentLinkViewController : UIViewController 
{
    DocumentManaged *document;
    Document *link;
    Attachment *currentAttachment;
    AttachmentsViewController *attachmentsViewController;
}
-(void) setDocument:(DocumentManaged *)aDocument
          linkIndex:(NSUInteger) aLinkIndex 
    attachmentIndex:(NSUInteger) anAttachmentIndex;
@end
