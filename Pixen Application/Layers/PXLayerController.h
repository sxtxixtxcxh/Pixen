//
//  PXLayerController.h
//  Pixen-XCode

// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  Created by Joe Osborn on Thu Feb 05 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "PXCanvas.h"

@class PXLayer, PXCanvas, PXDocument;
@interface PXLayerController : NSViewController <NSCollectionViewDelegate>
{
  @private
	IBOutlet NSCollectionView *layersView;
	PXCanvas *canvas;
	NSMutableArray *views;

	NSView *subview;
	IBOutlet NSButton *removeButton;
	PXDocument *document;
	int layersCreated;

	NSIndexSet *selection;
	
	//for programmatic expand/collapse
	CGFloat lastSubviewHeight;
}
-(id) initWithCanvas:(PXCanvas *)aCanvas;
- (void)setSubview:(NSView *)sv;
- (void)reloadData:(NSNotification *) aNotification;
- (void)setCanvas:(PXCanvas *) aCanvas;
- (PXCanvas *)canvas;
- (void)setDocument:(id)doc;

- (IBAction)addLayer: (id)sender;
- (IBAction)duplicateLayer: (id)sender;
- (void)duplicateLayerObject: (PXLayer *)layer;
- (IBAction)removeLayer: (id)sender;
- (void)removeLayerObject: (PXLayer *)layer;
- (IBAction)selectLayer: (id)sender;
- (void)selectRow:(NSUInteger)index;

- (IBAction)nextLayer: (id)sender;
- (IBAction)previousLayer: (id)sender;

- (void)mergeDown;

- (void)updateRemoveButtonStatus;

- (void)mergeDownLayerObject:(PXLayer *)layer;

- (NSUInteger)invertLayerIndex:(NSUInteger)anIndex;

- (void)deleteKeyPressedInCollectionView:(NSCollectionView *)cv;

@end
