//
//  LNSettingsReader.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNSettingsReader.h"

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
        
    }];
    
    [self endSession];
}
@end
