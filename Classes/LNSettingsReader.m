//
//  LNSettingsReader.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 14.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNSettingsReader.h"

@interface LNSettingsReader(Private)

-(void) removeBlankLogo;
-(NSString*) blankLogoPath;

@end

@implementation LNSettingsReader
-(void) sync
{
    __block LNSettingsReader *blockSelf = self;
    
    [self beginSession];
    [self jsonRequestWithUrl:[[self serverUrl] stringByAppendingString:@"/settings"] andHandler:^(BOOL err, id response)
    {
        if (err)
            return;

        NSDictionary *upload = [response objectForKey:@"upload"];
        NSString *url = [upload objectForKey:@"url"];
        NSString *field = [upload objectForKey:@"fileField"];
        
        if (!url || !field)
        {
            blockSelf.hasError = YES;
            NSLog(@"invalid settings");
            return;
        }
        
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        
        [currentDefaults setObject:url forKey:@"serverUploadUrl"];
        
        [currentDefaults setObject:field forKey:@"serverUploadFileField"];
        
        [currentDefaults synchronize];
        
        NSDictionary *resolution = [response objectForKey:@"resolution"];
        NSString *blankLogoUrl = [resolution objectForKey:@"logo"];
        NSString *blankLogoVersion = [resolution objectForKey:@"version"];
        
        NSString *currentBlankLogoVersion = [currentDefaults valueForKey:@"blankLogoVersion"];
        
        if (blankLogoUrl)
        {
            if (![currentBlankLogoVersion isEqualToString:blankLogoVersion])
            {

                [blockSelf fileRequestWithUrl:[[blockSelf serverUrl] stringByAppendingString:blankLogoUrl]
                                         path:[blockSelf blankLogoPath]
                                   andHandler:^(BOOL error, NSString* path)
                                   {
                                       if (error)
                                           [blockSelf removeBlankLogo];

                                       else
                                       {
                                           [currentDefaults setObject:blankLogoVersion forKey:@"blankLogoVersion"];
                                           [currentDefaults setObject:path forKey:@"blankLogoPath"];
                                           [currentDefaults synchronize];
                                       }
                                   }];
            }
        }
        else
            [blockSelf removeBlankLogo];
    }];
    
    [self endSession];
}

#pragma mark Private

-(void) removeBlankLogo
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSFileManager *df = [NSFileManager defaultManager];

    [currentDefaults removeObjectForKey:@"blankLogoVersion"];
    [currentDefaults removeObjectForKey:@"blankLogoPath"];
    [df removeItemAtPath:[self blankLogoPath] error:NULL];
    [currentDefaults synchronize];
    
}

-(NSString *) blankLogoPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *blankLogoPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    blankLogoPath = [blankLogoPath stringByAppendingPathComponent:@"BlankLogo.png"];
   
    return blankLogoPath;
}

@end
