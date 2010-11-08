//
//  Logger.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 09.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Logger.h"
#import "SynthesizeSingleton.h"

@interface Logger(Private)
-(NSString *) logPath;
@end

@implementation Logger
@synthesize redirectEnabled;

SYNTHESIZE_SINGLETON_FOR_CLASS(Logger);

- (void) setRedirectEnabled:(BOOL) value
{
    redirectEnabled = value;
    if (redirectEnabled)
    {
        //redirect NSLog to file
        //http://blog.coriolis.ch/2009/01/09/redirect-nslog-to-a-file-on-the-iphone/
        if (self.logPath)
            logFile = freopen([self.logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
        else
        {
            NSLog(@"Unable to redirect log to file");
            redirectEnabled = NO;
        }
        
    }
    else
    {
        if (logFile != NULL)
        {
            fclose(logFile);
            logFile = NULL;
        }
    }
}
-(void) removeLogFile
{
    self.redirectEnabled = NO;
    remove([self.logPath cStringUsingEncoding:NSASCIIStringEncoding]);
}

-(void) showLogForController:(UIViewController *) aController
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
        [mailController setSubject:@"iPapka log"];
        
        [mailController setMessageBody:logContent isHTML:NO]; 
        [controller presentModalViewController:mailController animated:YES];
        [mailController release];
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)mailController  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc 
{
    [controller release]; controller = nil;
    [logPath release]; logPath = nil;
    
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
