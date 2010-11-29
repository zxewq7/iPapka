#import "DocumentRoot.h"
#import "DataSource.h"
#import "NSDate+Additions.h"

@implementation DocumentRoot
-(void) accept
{
    self.statusValue = DocumentStatusAccepted;
    
    self.date = [NSDate date];
    
    self.dateStripped = [self.date stripTime];
	
	self.isEditableValue = NO;
}
-(void) decline
{
    self.statusValue = DocumentStatusDeclined;
    
    self.date = [NSDate date];
    
    self.dateStripped = [self.date stripTime];
	
	self.isEditableValue = NO;
}
@end