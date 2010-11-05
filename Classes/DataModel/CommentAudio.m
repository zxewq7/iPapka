#import "CommentAudio.h"
#import "Document.h"

@implementation CommentAudio
-(BOOL) isEditable
{
    return self.document.isEditable;
}
@end
