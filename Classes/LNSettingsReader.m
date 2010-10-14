//
//  LNSettingsReader.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 14.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LNSettingsReader.h"
#import "SBJsonParser.h"
#import "LNHttpRequest.h"

@implementation LNSettingsReader
-(void) sync
{
    self.allRequestsSent = NO;
    self.hasError = NO;
    
    LNHttpRequest *request = [self requestWithUrl:[[self serverUrl] stringByAppendingString:@"/settings"]];

    __block LNSettingsReader *blockSelf = self;
    
    request.requestHandler = ^(ASIHTTPRequest *request) {
        NSString *error = [request error] == nil?
        ([request responseStatusCode] == 200?
         nil:
         NSLocalizedString(@"Bad response", "Bad response")):
        [[request error] localizedDescription];
        if (error)
            NSLog(@"error fetching url %@\n%@", [request originalURL], error);
        else
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSError *error = nil;
            NSString *jsonString = [request responseString];
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
        }
        
    };
    [queue addOperation:request];
    self.allRequestsSent = YES;
}
@end
