//
//  PXCanvasDocument.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXDocument.h"

@class PXCanvas, PXCanvasController;

@interface PXCanvasDocument : PXDocument

@property (nonatomic, strong) PXCanvas *canvas;

+ (NSData *)dataRepresentationOfType:(NSString *)aType withCanvas:(PXCanvas *)canvas;
- (void)loadFromPasteboard:(NSPasteboard *)board;

- (PXCanvasController *)canvasController;

@end
