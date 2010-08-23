@class DocumentManaged;

@interface DocumentCellView : UIView {
	DocumentManaged *document;
	NSDateFormatter *dateFormatter;
	BOOL highlighted;
}

@property (nonatomic, retain, setter=setDocument:) DocumentManaged *document;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end
