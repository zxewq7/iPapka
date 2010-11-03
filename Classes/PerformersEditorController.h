//
//  ArrayEditorController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 03.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PerformersEditorController;

@class DocumentResolution;
@interface PerformersEditorController : UITableViewController 
{
    DocumentResolution *document;
    id target;
    SEL action;
}

@property (nonatomic, retain) DocumentResolution *document;
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@end
