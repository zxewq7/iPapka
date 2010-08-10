//
//  SwitchViewController.h
//  MultiViewiPad
//
//  Created by Chakra on 07/05/10.
//  Copyright 2010 Chakra Interactive Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentListViewController;
@class DocumentViewController;
@class Document;

@interface SwitchViewController : UIViewController {
	
	DocumentListViewController  *documentListViewController;
	DocumentViewController      *documentViewController;
    UIViewController            *currentView;
}

@property (nonatomic, retain) DocumentListViewController *documentListViewController;
@property (nonatomic, retain) DocumentViewController *documentViewController;

- (void) listDocuments;
- (void) showDocument:(Document *) anDocument;

@end
