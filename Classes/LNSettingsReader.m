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
-(void) run
{
    __block LNSettingsReader *blockSelf = self;
    
    [self jsonRequestWithUrl:[[self serverUrl] stringByAppendingString:@"/settings"] andHandler:^(NSError *err, id response)
    {
        if (err)
            return;

        NSDictionary *upload = [response objectForKey:@"upload"];
        NSString *url = [upload objectForKey:@"url"];
        NSString *field = [upload objectForKey:@"fileField"];
        
        if (!url || !field)
        {
            blockSelf.hasError = YES;
            AZZLog(@"invalid settings");
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
                                   andHandler:^(NSError *err1, NSString* path)
                                   {
                                       if (err1)
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
