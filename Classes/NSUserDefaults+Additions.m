//
//  NSUserDefaults+Additions.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 05.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSUserDefaults+Additions.h"


@implementation NSUserDefaults(Defaults)

//http://paulsolt.com/2009/06/iphone-default-user-settings-null/
+ (NSMutableDictionary *)defaultsFromSettingsBundle
{
    NSMutableDictionary *defaultsToRegister = [NSMutableDictionary dictionary];
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return defaultsToRegister;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    return defaultsToRegister;
}
@end
