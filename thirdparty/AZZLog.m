//  MLog.m

#import "AZZLog.h"

@implementation AZZLogger

+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber
		format:(NSString*)format, ...;
{
	va_list ap;
	NSString *print,*file;
	va_start(ap,format);
	file=[[NSString alloc] initWithBytes:sourceFile 
                                  length:strlen(sourceFile) 
                                encoding:NSUTF8StringEncoding];
	print=[[NSString alloc] initWithFormat:format arguments:ap];
	va_end(ap);
	//NSLog handles synchronization issues
	NSLog(@"%s:%d %@",[[file lastPathComponent] UTF8String],
		  lineNumber,print);
	[print release];
	[file release];
	
	return;
}
@end