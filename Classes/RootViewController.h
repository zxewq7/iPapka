//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged, AttachmentsViewController, ClipperViewController, Folder;

@interface RootViewController : UIViewController
{
    DocumentManaged            *document;
    AttachmentsViewController  *attachmentsViewController;
    UIToolbar                  *toolbar;
    ClipperViewController      *clipperViewController;
    Folder                     *folder;
}

@property (nonatomic, retain, setter=setDocument:) DocumentManaged *document;
@property (nonatomic, retain, setter=setFolder:)   Folder          *folder;
@end
