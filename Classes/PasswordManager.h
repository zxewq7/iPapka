//
//  PasswordDialog.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 04.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PasswordManager : NSObject<UIAlertViewDelegate>
{
    void (^passwordDialogHandler)(NSString *login, NSString *password, BOOL canceled);
}
+ (PasswordManager *)sharedPasswordManager;
-(void) credentials:(void (^)(NSString *login, NSString *password, BOOL canceled))handler;
@end