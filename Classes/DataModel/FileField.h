#import "_FileField.h"

@interface FileField : _FileField
@property (nonatomic, retain, readonly) NSString *filePath;
@property (readonly) BOOL isEditable;
@end
