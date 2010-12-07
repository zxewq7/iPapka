//
//  PasswordDialog.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 04.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KeychainItemWrapper;
@interface PasswordManager : NSObject<UIAlertViewDelegate>
{
    void (^passwordDialogHandler)(NSString *login, NSString *password, BOOL canceled);
    KeychainItemWrapper *wrapper;
}
+ (PasswordManager *)sharedPasswordManager;
- (void) credentials:(BOOL) requery handler:(void (^)(NSString *login, NSString *password, BOOL canceled))handler;
- (void) resetPassword;
@end
