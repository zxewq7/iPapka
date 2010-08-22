#import "DocumentCell.h"
#import "DocumentCellView.h"
#import "DocumentManaged.h"


@implementation DocumentCell

@synthesize documentCellView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		
		// Create a time zone view and add it as a subview of self's contentView.
		CGRect tzvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		documentCellView = [[DocumentCellView alloc] initWithFrame:tzvFrame];
		documentCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:documentCellView];
	}
	return self;
}


- (void)setDocument:(DocumentManaged *)newDocument
{
	documentCellView.document = newDocument;
}


- (void)dealloc {
	[documentCellView release];
    [super dealloc];
}


@end
