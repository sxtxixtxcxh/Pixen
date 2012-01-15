//
//  PXDocumentController.h
//  Pixen
//

@interface PXDocumentController: NSDocumentController
{
  @private
	BOOL cachedShowsToolPreview, cachedShowsPreviousCelOverlay;
	NSTimer *mouseTrackingTimer;
}

- (IBAction)newFromClipboard:sender;

- (BOOL)showsToolPreview;
- (BOOL)showsPreviousCelOverlay;

- (id)makeUntitledDocumentOfType:(NSString *)typeName showSizePrompt:(BOOL)showPrompt error:(NSError **)outError;

- (IBAction)newAnimationDocument:sender;

- (NSArray *)animationDocuments;
- (void)rescheduleAutosave;

@end

