//
//  PXCanvasPrintView.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@class PXCanvas;

@interface PXCanvasPrintView : NSView

+ (id)viewForCanvas:(PXCanvas *)aCanvas;

- (id)initWithCanvas:(PXCanvas *)aCanvas;

@end
