//
//  AttachmentPage.m
//  DataModel
//
//  Created by Vladimir Solomenchuk on 29.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttachmentPage.h"
#import "UIColor-Expanded.h"

@implementation AttachmentPage
@synthesize name, curves, isLoaded, hasError;
- (void) dealloc
{
    self.curves = nil;
    self.name = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.name = [coder decodeObjectForKey:@"name"];
        NSArray *loadedCurves = [coder decodeObjectForKey:@"curves"];
        NSMutableArray *xCurves = [NSMutableArray arrayWithCapacity:[loadedCurves count]];
        for (NSString *string in loadedCurves) 
        {
            NSArray *splitted = [string componentsSeparatedByString: @":"];
            NSObject *decodedObject = nil;
            if ([splitted count] == 4) //color
                decodedObject = [UIColor colorWithRed:[[splitted objectAtIndex:0] floatValue]
                                                 green:[[splitted objectAtIndex:1] floatValue]
                                                  blue:[[splitted objectAtIndex:2] floatValue] 
                                                 alpha:[[splitted objectAtIndex:3] floatValue]];
            else if ([splitted count] == 2) //point
                decodedObject = [NSValue valueWithCGPoint:CGPointMake([[splitted objectAtIndex:0] floatValue], [[splitted objectAtIndex:1] floatValue])];

            if (decodedObject) 
                [xCurves addObject:decodedObject];
        }

        self.curves = [NSArray arrayWithArray:xCurves];
        self.isLoaded = [[coder decodeObjectForKey:@"isLoaded"] boolValue];
        self.hasError = [[coder decodeObjectForKey:@"hasError"] boolValue];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: self.name forKey:@"name"];
    
    static NSString *pointFormat = @"%f:%f";
    NSMutableArray *savedCurves = [NSMutableArray arrayWithCapacity:[curves count]];
    for (NSObject *object in curves) 
    {
        NSString *encodedObject = nil;
        if ([object isKindOfClass:[UIColor class]])
        {
            UIColor *color = (UIColor *)object;
            encodedObject = [[color arrayFromRGBAComponents] componentsJoinedByString:@":"];
        }
        else if ([object isKindOfClass:[NSValue class]])
        {
            NSValue *value = (NSValue *) object;
            CGPoint point = [value CGPointValue];
            encodedObject = [NSString stringWithFormat:pointFormat, point.x, point.y];
        }
        
        if (encodedObject) 
            [savedCurves addObject:encodedObject];
    }
    
    [coder encodeObject: savedCurves forKey:@"curves"];
    [coder encodeObject: [NSNumber numberWithBool:self.hasError] forKey:@"hasError"];
    [coder encodeObject: [NSNumber numberWithBool:self.isLoaded] forKey:@"isLoaded"];
}

@end
