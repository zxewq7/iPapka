#import "DocumentSignature.h"

@implementation DocumentSignature

-(NSString *) audioCommentPath
{
    return [self.path stringByAppendingPathComponent:@"audioComment.caf"];
}
@end
