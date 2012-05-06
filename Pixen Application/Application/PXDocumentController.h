//
//  PXDocumentController.h
//  Pixen
//

@interface PXDocumentController: NSDocumentController
{
  @private
	BOOL cachedShowsPreviousCelOverlay;
}

- (IBAction)newFromClipboard:sender;

- (BOOL)showsPreviousCelOverlay;

- (id)makeUntitledDocumentOfType:(NSString *)typeName showSizePrompt:(BOOL)showPrompt error:(NSError **)outError;

- (IBAction)newAnimationDocument:sender;

- (NSArray *)animationDocuments;

@end

