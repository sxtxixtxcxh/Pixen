//
//  PXDocument.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@class PXCanvas, PXCanvasWindowController;

@interface PXDocument : NSDocument

@property (nonatomic, retain) PXCanvasWindowController *windowController;

- (PXCanvas *)canvas;
- (NSArray *)canvases;
- (BOOL)containsCanvas:(PXCanvas *)canvas;

- (void)initWindowController;
- (void)setWindowControllerData;
- (void)makeWindowControllers;

- (NSString *)frameAutosaveName;

@end
