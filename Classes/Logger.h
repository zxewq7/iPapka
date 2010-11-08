//
//  Logger.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 09.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface Logger : NSObject<MFMailComposeViewControllerDelegate>
{
    BOOL redirectEnabled;
    NSString *logPath;
    UIViewController * controller;
    FILE *logFile;
}
+ (Logger *)sharedLogger;
@property (nonatomic) BOOL redirectEnabled;
-(void) showLogForController:(UIViewController *) controller;
-(void) removeLogFile;
@end
