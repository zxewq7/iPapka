//
//  LNSettingsReader.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNSettingsReader.h"
#import "SBJsonParser.h"

@implementation LNSettingsReader
-(void) sync
{
    self.allRequestsSent = NO;
    self.hasError = NO;
    
    __block LNSettingsReader *blockSelf = self;
    
    [self sendRequestWithUrl:[[self serverUrl] stringByAppendingString:@"/settings"] andHandler:^(BOOL err, NSString *response){
        if (err)
            return;

        SBJsonParser *json = [[SBJsonParser alloc] init];
        NSError *error = nil;
        NSString *jsonString = response;
        NSDictionary *parsedResponse = [json objectWithString:jsonString error:&error];
        [json release];
        if (parsedResponse == nil)
        {
            blockSelf.hasError = YES;
            NSLog(@"error parsing response, error:%@ response: %@", error, jsonString);
            return;
        }
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
