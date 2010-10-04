//
//  NSFileManager+Additions.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 21.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "NSFileManager+Additions.h"


@implementation NSFileManager(NSFileManagerAdditions)
+(NSString *) tempFileName:(NSString *) prefix
{
    NSString *tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:[prefix stringByAppendingString: @".XXXXXX"]];
    
    const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
    
    char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
    
    strcpy(tempFileNameCString, tempFileTemplateCString);
    
    int fileDescriptor = mkstemp(tempFileNameCString);
    
    if (fileDescriptor == -1) //unable to create
    {
        free(tempFileNameCString);
        return nil;
    }
    
    // This is the file name if you need to access the file by name, otherwise you can remove
    // this line.
    NSString *tempFileName = [[NSFileManager defaultManager]
                              stringWithFileSystemRepresentation:tempFileNameCString
                              length:strlen(tempFileNameCString)];
    
    free(tempFileNameCString);
    
    close(fileDescriptor);
    
    return tempFileName;
}
@end
