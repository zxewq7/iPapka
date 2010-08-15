@class Document;
@class DocumentCellView;

@interface DocumentCell : UITableViewCell {
	DocumentCellView *documentCellView;
}

- (void)setDocument:(Document *)newDocument;
@property (nonatomic, retain) DocumentCellView *documentCellView;

@end
