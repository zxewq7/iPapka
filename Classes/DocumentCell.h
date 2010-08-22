@class DocumentManaged;
@class DocumentCellView;

@interface DocumentCell : UITableViewCell {
	DocumentCellView *documentCellView;
}

- (void)setDocument:(DocumentManaged *)newDocument;
@property (nonatomic, retain) DocumentCellView *documentCellView;

@end
