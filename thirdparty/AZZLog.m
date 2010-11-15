//  MLog.m

#import "AZZLog.h"
#import "SynthesizeSingleton.h"

@interface AZZLogger(Private)
-(NSString *) logPath;
@end

@implementation AZZLogger
@synthesize logFile;

SYNTHESIZE_SINGLETON_FOR_CLASS(AZZLogger);

+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber
		format:(NSString*)format, ...;
{
	va_list ap;
	NSString *print, *file, *print1;
	va_start(ap,format);
	file=[[NSString alloc] initWithBytes:sourceFile 
                                  length:strlen(sourceFile) 
                                encoding:NSUTF8StringEncoding];

	print=[[NSString alloc] initWithFormat:format arguments:ap];
	va_end(ap);
    print1=[[NSString alloc] initWithFormat:@"%s:%d %@",[[file lastPathComponent] UTF8String],
            lineNumber,print];
	//NSLog handles synchronization issues
    @synchronized(self)
    {
        AZZLogger *slf = [AZZLogger sharedAZZLogger];
        if (slf.logFile)
            [slf.logFile writeData:[print1 dataUsingEncoding:NSUTF8StringEncoding]];

        NSLog(@"%@", print1);

    }
    
	[print release];
    [print1 release];
	[file release];
	
	return;
}

-(id)init
{
    if ((self = [super init])) 
    {
        logFile = [NSFileHandle fileHandleForWritingAtPath: self.logPath];
    }
    return self;
}

-(void) removeLogFile
{
    [logFile closeFile]; [logFile release]; logFile = nil;
    remove([self.logPath cStringUsingEncoding:NSASCIIStringEncoding]);
}

-(void) sendLogTo:(NSString *)email withSubject:(NSString *) subject andController:(UIViewController *) aController;
{
    if (controller != aController)
    {
        [controller release];
        controller = [aController retain];
    }
    
    
    if (self.logPath)
    {
        NSString *logContent = [NSString stringWithContentsOfFile:self.logPath encoding:NSUTF8StringEncoding error:NULL];
        
        MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setToRecipients:[NSArray arrayWithObject:email]];
        [mailController setSubject:subject];
        
        [mailController setMessageBody:logContent isHTML:NO]; 
        [controller presentModalViewController:mailController animated:YES];
        [mailController release]; mailController = nil;
    }
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc 
{
    [controller release]; controller = nil;
    [logPath release]; logPath = nil;
    [logFile closeFile];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Private
-(NSString *) logPath
{
    if (!logPath)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
        [logPath retain];
    }
    return logPath;
}
@end