#import "PXPaletteView.h"
#import "PXColorPickerColorWellCell.h"

@implementation PXPaletteView

const int viewMargin = 1;

- (void)setDelegate:del
{
	delegate = del;
}

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		insertionIndex = -1;
		floatingIndex = -1;
		selectedIndex = -1;
		paletteIndices = [[NSMutableArray alloc] initWithCapacity:32000];
		colorCell = [[PXColorPickerColorWellCell alloc] init];
		[self setEnabled:YES];
		controlSize = NSRegularControlSize;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged:) name:PXPaletteChangedNotificationName object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[colorCell release];
	[paletteIndices release];
	[super dealloc];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)setEnabled:(BOOL)en
{
	enabled = en;
}

- (void)reloadData
{
	[paletteIndices removeAllObjects];
	if(!palette)
	{
		return;
	}
	int i;
	for(i = 0; i < PXPalette_colorCount(palette); i++)
	{
		[paletteIndices addObject:[NSNumber numberWithInt:i]];
	}
	if(showsNewSwatch)
	{
		[paletteIndices addObject:[NSNumber numberWithInt:-1]];
	}
}

- (void)resizeWithOldSuperviewSize:(NSSize)size
{
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] bounds]), MAX(rows * height + viewMargin*2, NSHeight([[self superview] bounds])))];
	[self retile];
}

- (void)retile
{
	width = (controlSize == NSRegularControlSize ? 32 : 16) + viewMargin;
	height = width;
	columns = NSWidth([self bounds]) / width;
	rows = palette ? ceilf((float)((PXPalette_colorCount(palette) + (showsNewSwatch ? 1 : 0))) / columns) : 0;
	
	float difference = NSWidth([self bounds]) - columns * width - viewMargin*2;
	float additional = difference / (float)(columns);
	width = width+additional;
	
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] bounds]), MAX(rows * height + viewMargin*2, NSHeight([[self superview] bounds])))];
}

- (PXPalette *)palette
{
	return palette;
}

- (BOOL)acceptsFirstMouse:event
{
	return YES;
}

- (void)paletteChanged:note
{
	[self retile];
	[self reloadData];
	[self setNeedsDisplay:YES];
}

- (void)setPalette:(PXPalette *)pal
{
	[self floatIndex:-1];
	PXPalette_retain(pal);
	PXPalette_release(palette);
	palette = pal;		
	showsNewSwatch = (!(pal->locked) || (pal->canSave)) && !(pal->isSystemPalette);
	[self setEditable:!(pal->isSystemPalette)];
	[self retile];
	[self reloadData];
	[self setNeedsDisplay:YES];
}

- (PXColorCelState)stateForCelIndex:(int)index
{
	return (selectedIndex == index && index != -1) ? PXSelectedColor : PXNoToolColor;
}

- (void)drawRect:(NSRect)rect
{
	NSEraseRect(rect);
	
	if (!palette) { return; }
	// Okay, so with the rect we're given, we first determine the rows that are visible.
	// Make sure not to go past the bounds of our array.
	int firstRow = MAX(floorf(NSMinY(rect) / height), 0);
	int lastRow = MIN(ceilf(NSMaxY(rect) / height), rows-1);
	// We just go ahead and round them to the appropriate number; we're not particularly
	// worried about drawing all of the cells that are only partially showing: drawing
	// cells is cheap.
	
#warning Hacky workaround.  But the real problem seems very hard to locate.
	@try {
		// Draw the appropriate cells.
		int i, j;
		NSColor **colors = palette->colors;
		[colorCell setControlSize:controlSize];
		for (j = firstRow; j <= lastRow; j++)
		{
			for (i = 0; i < columns; i++)
			{
				int index = j * columns + i;
				if (index >= (PXPalette_colorCount(palette) + (showsNewSwatch ? 1 : 0))) { break; }
				int paletteIndex = [[paletteIndices objectAtIndex:index] intValue];
				[colorCell setIndex:paletteIndex];
				NSColor *color = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
				if(paletteIndex == -1)
				{
					[colorCell setHighlighted:newSwatchTinted];
				}
				else
				{
					color = colors[paletteIndex];
					[colorCell setHighlighted:NO];
				}
				[colorCell setColor:color];
				[colorCell setState:[self stateForCelIndex:paletteIndex]];
				[colorCell drawWithFrame:NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2) inView:self];
			}
		}
	} @catch(NSException *e) {
		[self reloadData];
		[self retile];
		[self display];
	}
	if(!enabled)
	{
		[[NSColor colorWithCalibratedWhite:1 alpha:.2] set];
		NSRectFillUsingOperation([self visibleRect], NSCompositeSourceOver);
	}
}

- (void)floatIndex:(int)index
{
	floatingIndex = index;
	[self retile];
	[self setNeedsDisplay:YES];	
}

- (void)setEditable:(BOOL)ed
{
	[self floatIndex:-1];
	isEditable = ed;
	[self reloadData];
}

- (void)rightMouseDown:event
{
	[self mouseDown:event];
}

- (void)rightMouseDragged:event
{
	[self mouseDragged:event];
}

- (void)rightMouseUp:event
{
	[self mouseUp:event];
}

- (int)indexOfCelAtPoint:(NSPoint)point
{
	int firstRow = MAX(floorf(NSMinY([self visibleRect]) / height), 0);
	int lastRow = MIN(ceilf(NSMaxY([self visibleRect]) / height), rows-1);
	int i, j;
	for (j = firstRow; j <= lastRow; j++)
	{
		for (i = 0; i < columns; i++)
		{
			int index = j * columns + i;
			if (index >= (PXPalette_colorCount(palette) + (showsNewSwatch ? 1 : 0))) { break; }
			NSRect frame = NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2);
			if(NSPointInRect(point, frame))
			{
				return [[paletteIndices objectAtIndex:index] intValue];
			}			
		}
	}	
	return -1;
}

- (NSControlSize)controlSize
{
	return controlSize;
}

- (void)setControlSize:(NSControlSize)aSize
{
	controlSize = aSize;
	[self retile];
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (void)sizeSelector:selector selectedSize:(NSControlSize)aSize
{
	[self setControlSize:aSize];
	if ([delegate respondsToSelector:@selector(paletteViewSizeChangedTo:)])
	{
		[delegate paletteViewSizeChangedTo:aSize];
	}
}

- (void)mouseDown:event
{
	if(!enabled) { return; }
	int paletteIndex = [self indexOfCelAtPoint:	[self convertPoint:[event locationInWindow] fromView:nil]];
	if (paletteIndex == -1)
	{
		if (NSPointInRect([self convertPoint:[event locationInWindow] fromView:nil], NSMakeRect(viewMargin*2 + (PXPalette_colorCount([self palette]) % columns)*width, viewMargin*2 + (rows-1)*height, width - viewMargin*2, height - viewMargin*2)))
		{
			newSwatchTinted = YES;
			[self setNeedsDisplayInRect:[self visibleRect]];
		}
		return;
	}
	
	if (isEditable)
	{
		[self floatIndex:paletteIndex];
	}
	else
	{
		[delegate useColorAtIndex:paletteIndex event:event];
		[self floatIndex:-1];
	}
	selectedIndex = paletteIndex;
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (void)mouseDragged:event
{
	if (!palette || !isEditable || !enabled) { return; }
	
	if(floatingIndex == (PXPalette_colorCount(palette)) || floatingIndex == -1) { return; }
	NSPoint loc = [self convertPoint:[event locationInWindow] fromView:nil];
	if(!NSPointInRect(loc, [self bounds]))
	{
		if(PXPalette_colorCount(palette) <= 1) { return; }
		outside = YES;
	}
	else
	{
		outside = NO;
		int firstRow = MAX(floorf(NSMinY([self visibleRect]) / height), 0);
		int lastRow = MIN(ceilf(NSMaxY([self visibleRect]) / height), rows-1);
		int i, j;
		for (j = firstRow; j <= lastRow; j++)
		{
			for (i = 0; i < columns; i++)
			{
				int index = j * columns + i;
				NSRect frame = NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2);
				if(NSPointInRect(loc, frame))
				{
					insertionIndex = index;					
					if(insertionIndex >= PXPalette_colorCount(palette))
					{
						insertionIndex = PXPalette_colorCount(palette) - 1;
					}
					int floatIndex = [paletteIndices indexOfObject:[NSNumber numberWithInt:floatingIndex]];
					[paletteIndices removeObjectAtIndex:floatIndex];
					[paletteIndices insertObject:[NSNumber numberWithInt:floatingIndex] atIndex:insertionIndex];
					break;
				}
			}
		}
	}
	[self retile];
	[self setNeedsDisplay:YES];
	[self autoscroll:event];
}

- (void)setDocument:doc
{
	document = doc;
}

- (void)mouseUp:event
{
	if(!enabled) { return; }
	if(outside)
	{
		if(PXPalette_colorCount(palette) <= 1) { return; }
		[[document undoManager] beginUndoGrouping];
		PXPalette_setColorAtIndex(palette, [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0], floatingIndex);
		[[document undoManager] setActionName:NSLocalizedString(@"Modify Palette", @"Modify Palette")];
		[[document undoManager] endUndoGrouping];	
		previousFloatingIndex = -1;
		[self floatIndex:-1];
		insertionIndex = -1;
		outside = NO;
		[self reloadData];
		[self setNeedsDisplay:YES];
		return;
	}
	previousFloatingIndex = floatingIndex;
	int firstRow = MAX(floorf(NSMinY([self visibleRect]) / height), 0);
	int lastRow = MIN(ceilf(NSMaxY([self visibleRect]) / height), rows-1);
	int i, j;
	for (j = firstRow; j <= lastRow; j++)
	{
		for (i = 0; i < columns; i++)
		{
			int index = j * columns + i;
			if (index >= (PXPalette_colorCount(palette) + (showsNewSwatch ? 1 : 0))) { break; }
			NSRect frame = NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2);
			if(NSPointInRect([self convertPoint:[event locationInWindow] fromView:nil], frame))
			{
				if(insertionIndex == -1)
				{
					previousFloatingIndex = index;
					if([event clickCount] >= 2 && isEditable)
					{
						[[document undoManager] beginUndoGrouping];
						[delegate modifyColorAtIndex:index];
						[[document undoManager] setActionName:NSLocalizedString(@"Modify Palette", @"Modify Palette")];
						[[document undoManager] endUndoGrouping];
					}
					else
					{
						if([[paletteIndices objectAtIndex:index] intValue] != -1)
						{
							[delegate useColorAtIndex:index event:event];
						}
						else
						{
							[[document undoManager] beginUndoGrouping];
							newSwatchTinted = NO;
							[self setNeedsDisplayInRect:[self visibleRect]];
							PXPalette_addColor(palette, [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1]);
							[self setSelectedIndex:index];
							[delegate modifyColorAtIndex:index];
							[[document undoManager] setActionName:NSLocalizedString(@"Modify Palette", @"Modify Palette")];
							[[document undoManager] endUndoGrouping];
						}
					}	
					return;
				}
				BOOL adjustIndices = (document && !([event modifierFlags] & NSAlternateKeyMask));
				[[document undoManager] beginUndoGrouping];
				PXPalette_moveColorAtIndexToIndex(palette,floatingIndex,insertionIndex,adjustIndices);
				[[document undoManager] setActionName:NSLocalizedString(@"Modify Palette", @"Modify Palette")];
				[[document undoManager] endUndoGrouping];
				break;
			}
		}
	}
	if (insertionIndex != -1 && insertionIndex != floatingIndex)
	{
		[self setSelectedIndex:insertionIndex];
		[delegate useColorAtIndex:insertionIndex event:event];
	}
	[self floatIndex:-1];
	insertionIndex = -1;
	outside = NO;
	newSwatchTinted = NO;
	[self reloadData];
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (void)setSelectedIndex:(int)index
{
	selectedIndex = index;
	[self setNeedsDisplayInRect:[self visibleRect]];
}

@end
