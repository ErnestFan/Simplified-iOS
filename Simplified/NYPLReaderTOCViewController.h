@class NYPLReaderRendererOpaqueLocation;
@class NYPLReaderTOCViewController;
@class RDNavigationElement;
@class NYPLReaderBookmark;

@protocol NYPLReaderTOCViewControllerDelegate

- (void)TOCViewController:(NYPLReaderTOCViewController *)controller
didSelectOpaqueLocation:(NYPLReaderRendererOpaqueLocation *)opaqueLocation;

- (void)TOCViewController:(NYPLReaderTOCViewController *)controller
didSelectBookmark:(NYPLReaderBookmark *)bookmark;

@end

@interface NYPLReaderTOCViewController : UIViewController

@property (nonatomic, weak) id<NYPLReaderTOCViewControllerDelegate> delegate;
@property (nonatomic) NSArray *tableOfContents;
@property (nonatomic) NSMutableArray<NYPLReaderBookmark *> *bookmarks;
@property (nonatomic) NSString *bookTitle;
@property (nonatomic) NSString *currentChapter;


@end
