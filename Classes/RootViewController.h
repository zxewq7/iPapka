//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentManaged, AttachmentsViewController, ClipperViewController;

@interface RootViewController : UIViewController
{
    DocumentManaged            *document;
    AttachmentsViewController  *attachmentsViewController;
    UIToolbar                  *toolbar;
    ClipperViewController      *clipperViewController;
}

@property (nonatomic, retain, setter=setDocument:) DocumentManaged *document;
@end
