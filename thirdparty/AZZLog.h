//  MLog.h

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#define AZZLog(s,...) \
[AZZLogger logFile:__FILE__ lineNumber:__LINE__ \
format:(s),##__VA_ARGS__]

@interface AZZLogger : NSObject<MFMailComposeViewControllerDelegate>
{
    NSString *logPath;
    UIViewController * controller;
    NSFileHandle *logFile;
}
+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber 
		format:(NSString*)format, ...;
+ (AZZLogger *)sharedAZZLogger;

-(void) sendLogTo:(NSString *)email withSubject:(NSString *) subject andController:(UIViewController *) aController;
-(void) removeLogFile;
@property (readonly) NSFileHandle * logFile;
@end