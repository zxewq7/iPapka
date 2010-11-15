//  MLog.h

#import <UIKit/UIKit.h>

#define AZZLog(s,...) \
[AZZLogger logFile:__FILE__ lineNumber:__LINE__ \
format:(s),##__VA_ARGS__]

@interface AZZLogger : NSObject
+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber 
		format:(NSString*)format, ...;
@end