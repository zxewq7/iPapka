//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Document;

@interface DocumentViewController : UIViewController
{
    UIToolbar *toolbar;
    UILabel   *documentTitle;
    Document  *document;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UILabel   *documentTitle;

@property (nonatomic, retain, setter=setDocument:) Document  *document;

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
@end
