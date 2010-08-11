//
//  LNDataSource.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LNDataSource.h"
#import "Document.h"
#import "Attachment.h"
#import "SynthesizeSingleton.h"

@implementation LNDataSource
SYNTHESIZE_SINGLETON_FOR_CLASS(LNDataSource);

-(id)init
{
    if ((self = [super init])) {
        _documents = [[NSMutableArray alloc] init];
        [_documents retain];
        
        for(int i=0;i<100;i++)
        {
            Document *document = [[Document alloc] init];
            document.icon =  [UIImage imageNamed: @"Signature.png"];
            document.title = [NSString stringWithFormat:@"Document #%d", i];
            document.uid = [NSString stringWithFormat:@"document #%d", i];
            
            NSMutableArray *attachments = [[NSMutableArray alloc] init];
            for (int ii=0;ii<10;ii++)
            {
                Attachment *attachment = [[Attachment alloc] init];
                attachment.title = [NSString stringWithFormat:@"Attachment #%d", ii];
                [attachments addObject:attachment];
                [attachment release];
            }
            document.attachments = attachments;
            [attachments release];
            [(NSMutableArray *)_documents addObject:document];
            [document release];
        }
    }
    return self;
}

- (NSUInteger) count
{
    return [_documents count];
}

- (Document *) documentAtIndex:(NSUInteger) anIndex
{
    return [_documents objectAtIndex:anIndex];
}
@end
