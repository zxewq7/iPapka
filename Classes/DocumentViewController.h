//
//  DocumentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchViewController;

@interface DocumentViewController : UIViewController {
    SwitchViewController *switchViewController;
}
@property (nonatomic, retain) SwitchViewController *switchViewController;
- (void) showDocumentList:(id) sender;
@end
