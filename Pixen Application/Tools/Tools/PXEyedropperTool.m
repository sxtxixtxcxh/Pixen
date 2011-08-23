  //  PXEyedropperTool.m
  //  Pixen
  //
  // Copyright (c) 2003,2004,2005 Pixen

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

  //  Created by Joe Osborn on Mon Oct 13 2003.
  //  Copyright (c) 2003 Pixen. All rights reserved.
  //

#import "PXEyedropperTool.h"

#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasController.h"
#import "PXEyedropperToolPropertiesController.h"
#import "PXToolPaletteController.h"
#import "PXToolSwitcher.h"

@implementation PXEyedropperTool

#define EYE_PC ((PXEyedropperToolPropertiesController *) self.propertiesController)

- (NSString *)name
{
	return NSLocalizedString(@"EYEDROPPER_NAME", @"Eyedropper Tool");
}

- (PXToolPropertiesController *)createPropertiesController
{
	return [[PXEyedropperToolPropertiesController new] autorelease];
}

-  (NSCursor *)cursor
{
	return [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"eyedropper_bw.png"]
									hotSpot:NSMakePoint(14.0f, 14.0f)] autorelease];
}

/*

- propertiesView
{
    //FIXME immense HACK ohgodimsorry
	if ([[PXToolPaletteController sharedToolPaletteController] leftTool] == self)
		[(PXEyedropperToolPropertiesController *) self.propertiesController setButtonType:PXLeftButtonTool];
	else
		[(PXEyedropperToolPropertiesController *) self.propertiesController setButtonType:PXRightButtonTool];
	
	return propertiesView;	
}

 */

-(NSColor *) compositeColorAtPoint:(NSPoint)aPoint
                        fromCanvas:(PXCanvas *)canvas
{
	if (![canvas containsPoint:aPoint]) 
  { 
		return nil; 
  }
	else 
  {
		if ([EYE_PC colorSource] == PXActiveLayerColorSource)
		{
			return [[canvas activeLayer] colorAtPoint:aPoint];
		}
		else
		{
      return [canvas surfaceColorAtPoint:aPoint];
		}
	}
}	

- (void)eyedropAtPoint:(NSPoint)aPoint 
  fromCanvasController:(PXCanvasController *)controller
{
	if(![[controller canvas] containsPoint:aPoint]) { return; }
	PXToolSwitcher *usedSwitcher;
	
	if ([EYE_PC buttonType] == PXLeftButtonTool)
		usedSwitcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	else
		usedSwitcher = [[PXToolPaletteController sharedToolPaletteController] rightSwitcher];
	
	[usedSwitcher setColor:[self compositeColorAtPoint:aPoint 
                                          fromCanvas:[controller canvas]]];
}


- (void)mouseDownAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *) controller
{
	[self eyedropAtPoint:aPoint fromCanvasController:controller];
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint 
                      to:(NSPoint)finalPoint
    fromCanvasController:(PXCanvasController *)controller
{
	[self eyedropAtPoint:finalPoint fromCanvasController:controller];
}

- (void)mouseUpAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *)controller
{
	[self eyedropAtPoint:aPoint fromCanvasController:controller];   
}


@end
