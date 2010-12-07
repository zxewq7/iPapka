//
//  PasswordDialog.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 04.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PasswordManager.h"
#import "SynthesizeSingleton.h"
#import "KeychainItemWrapper.h"

#define kLoginFieldTag 1001
#define kPasswordFieldTag 1002

@implementation PasswordManager
SYNTHESIZE_SINGLETON_FOR_CLASS(PasswordManager);

- (id)init 
{
    if ((self = [super init])) 
    {
        wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
    }
    return self;
}

- (void) resetPassword
{
	[wrapper resetKeychainItem];
	[wrapper release];
	//recreate wrapper after reset
	wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
}

- (void) credentials:(BOOL) requery handler:(void (^)(NSString *login, NSString *password, BOOL canceled))handler
{
    NSString *login = [wrapper objectForKey:(NSString *)kSecAttrAccount];
    NSString *password = [wrapper objectForKey:(NSString *)kSecValueData];

    if (!requery)
    {
        if (login && password && ![login isEqualToString:@""] && ![password isEqualToString:@""])
        {
            if (handler)
                handler(login, password, NO);
            return;
        }
    }
    [passwordDialogHandler release];
    
    passwordDialogHandler = [handler copy];
    
    UITextField *textField;
    UITextField *textField2;
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Username and password", "Username and password")
                                                     message:@"\n\n\n" // IMPORTANT
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", "Cancel")
                                           otherButtonTitles:NSLocalizedString(@"OK", "OK"),
                           nil];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)]; 
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setPlaceholder:NSLocalizedString(@"Username", "Username")];
    textField.text = login;
    textField.tag = kLoginFieldTag;
    [prompt addSubview:textField];
    
    textField2 = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 85.0, 260.0, 25.0)]; 
    [textField2 setBackgroundColor:[UIColor whiteColor]];
    [textField2 setPlaceholder:NSLocalizedString(@"Password", "Password")];
    [textField2 setSecureTextEntry:YES];
    textField2.tag = kPasswordFieldTag;
    [prompt addSubview:textField2];
    
    // set place
#warning next string obsoleted in iOS4
    [prompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
    
    [prompt show];
    [prompt release];
    
    // set cursor and show keyboard
    if (login && ![login isEqualToString:@""])
        [textField2 becomeFirstResponder];
    else
        [textField becomeFirstResponder];       
    
    [textField2 release];
    [textField release];
}

- (void)dealloc 
{
    [passwordDialogHandler release];
    [wrapper release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *loginField = (UITextField *)[alertView viewWithTag:kLoginFieldTag];
    UITextField *passwordField = (UITextField *)[alertView viewWithTag:kPasswordFieldTag];
    NSString *login = loginField.text;
    NSString *password = passwordField.text;

    BOOL canceled = (buttonIndex == 0);
    
    if (!canceled)
    {
        [wrapper setObject:login forKey: (NSString *)kSecAttrAccount];
        [wrapper setObject:password forKey: (NSString *)kSecValueData];
    }
    
    if (passwordDialogHandler)
        passwordDialogHandler(login, password, canceled);
    
    [passwordDialogHandler release];
    passwordDialogHandler = nil;

}
@end
