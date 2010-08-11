//
//  LNDataSource.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Document;
@interface LNDataSource : NSObject
{
    NSArray *_documents;
}
+ (LNDataSource *)sharedLNDataSource;
-(NSUInteger) count;
-(Document *) documentAtIndex:(NSUInteger) anIndex;
@end
