//
//  PXDocument.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXCanvas, PXCanvasPrintView, PXCanvasWindowController;

@interface PXDocument : NSDocument
{
  @private
	PXCanvasPrintView *_printableView;
}

@property (nonatomic, strong) PXCanvasWindowController *windowController;

- (PXCanvas *)canvas;
- (NSArray *)canvases;
- (BOOL)containsCanvas:(PXCanvas *)canvas;

- (void)initWindowController;
- (void)setWindowControllerData;
- (void)makeWindowControllers;

- (NSString *)frameAutosaveName;

- (NSString *)lastSavedFileTypeKey;
- (NSString *)defaultFileType;

@end
