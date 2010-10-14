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
    self.allRequestsSent = NO;
    self.hasError = NO;
    
    __block LNSettingsReader *blockSelf = self;
    
    [self jsonRequestWithUrl:[[self serverUrl] stringByAppendingString:@"/settings"] andHandler:^(BOOL err, NSObject *response)
    {
        if (err)
            return;

        NSDictionary *parsedResponse = (NSDictionary *)response;

        NSDictionary *upload = [parsedResponse objectForKey:@"upload"];
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
    
    self.allRequestsSent = YES;
}
@end
