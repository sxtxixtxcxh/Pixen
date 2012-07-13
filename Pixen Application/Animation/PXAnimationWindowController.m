//
//  PXAnimationWindowController.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXAnimationWindowController.h"

#import "NSImage+Reps.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_Selection.h"
#import "PXCanvasController.h"
#import "PXAnimation.h"
#import "PXCel.h"
#import "PXFilmStripView.h"
#import "PXSequenceExportPrompter.h"
#import "PXCanvasDocument.h"
#import "PXAnimationView.h"
#import "OSQTExporter.h"
#import "PXCanvasWindowController_IBActions.h"
#import "Constants.h"

@implementation PXAnimationWindowController

@synthesize animation;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[filmStrip setDataSource:nil];
	[filmStrip setDelegate:nil];
	[self setAnimation:nil];
	[super dealloc];
}

- (void)canvasDidChange:notification
{
	NSRect celRect = [filmStrip rectOfCelIndex:[filmStrip selectedIndex]];
	float scaledRatio = NSWidth(celRect) / [activeCel size].width;
	NSRect changedRect = [[[notification userInfo] objectForKey:PXChangedRectKey] rectValue];
	changedRect.origin.x *= scaledRatio;
	changedRect.origin.x += NSMinX(celRect);
	changedRect.origin.y *= scaledRatio;
	changedRect.origin.y += NSMinY(celRect);
	changedRect.size.width *= scaledRatio;
	changedRect.size.height *= scaledRatio;
	[filmStrip setNeedsDelayedDisplayInRect:changedRect];
	if([notification object] == [activeCel canvas]) { return; }
	NSUInteger i;
	for (i = 0; i < [self numberOfCels]; i++)
	{
		PXCel *current = [self celAtIndex:i];
		if([current canvas] == [notification object])
		{
			[self activateCel:current];
		}
	}
}

- (void)activateCel:(PXCel *)cel
{
	NSInteger newCelIndex = [animation indexOfObjectInCels:cel];
		
	if(cel == activeCel && activeIndex == newCelIndex) { return; }
	activeIndex = newCelIndex;
	activeCel = cel;
	[self setCanvas:[cel canvas]];
	NSInteger prevIndex = newCelIndex - 1;
	if (prevIndex < 0)
		prevIndex = [self numberOfCels] ? [self numberOfCels] - 1 : 0;
	if (newCelIndex != prevIndex)
	{
		NSBitmapImageRep *imageRep = [[[self celAtIndex:prevIndex] canvas] imageRep];
		NSImage *image = [NSImage imageWithBitmapImageRep:imageRep];
		
		[(PXAnimationView *)[self view] setPreviousCelImage:image];
	}
	else
	{
		[(PXAnimationView *)[self view] setPreviousCelImage:nil];
	}
	[filmStrip selectCelAtIndex:newCelIndex byExtendingSelection:NO];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canvasDidChange:) name:PXCanvasChangedNotificationName object:nil];
	[(NSClipView *)[filmStrip superview] setCopiesOnScroll:NO]; // prevent weird visual bugs
	[super awakeFromNib];
}

- (void)updateDeleteButtonState
{
	[self willChangeValueForKey:@"canDeleteCel"];
	[self didChangeValueForKey:@"canDeleteCel"];	
}

- (void)setAnimation:anim
{
	[animation removeObserver:self forKeyPath:@"countOfCels"];
	[animation removeObserver:self forKeyPath:@"size"];
	animation = anim;
	if (!animation) {
		[self setCanvas:nil];
	} else {
		[animation addObserver:self forKeyPath:@"countOfCels" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
		[animation addObserver:self forKeyPath:@"size" options:NSKeyValueObservingOptionNew context:NULL];
		[self updateDeleteButtonState];
		//reload data
		[animation setUndoManager:[[self document] undoManager]];
		[self activateCel:[self celAtIndex:0]];
		if(!NSEqualSizes([anim size], NSZeroSize))
		{
			[filmStrip reloadData];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context
{
	[filmStrip reloadData];
	
	if ([keyPath isEqualToString:@"countOfCels"]) {
		// If the change involved the number of cels getting bigger, this means a new cel was added; we should activate it.
		if ([[change objectForKey:NSKeyValueChangeOldKey] intValue] < [animation countOfCels])
		{
			[self activateCel:[self celAtIndex:MIN([filmStrip selectedIndex]+1, [animation countOfCels]-1)]];
		}
		// It's gone down, so select the next one down.
		else if([[change objectForKey:NSKeyValueChangeOldKey] intValue] > [animation countOfCels])
		{
			[self activateCel:[self celAtIndex:MAX((NSInteger)([filmStrip selectedIndex])-1, 0)]];
		}
		else
		{
			[self activateCel:activeCel];
		}
		
		[self updateDeleteButtonState];
	} else if ([keyPath isEqualToString:@"size"]) {
		[self.canvasController updateCanvasSize];
	}
}

- (NSUInteger)numberOfCels
{
	return NSEqualSizes([animation size], NSZeroSize) ? 0 : [animation countOfCels];
}

- (void)writeCelsAtIndices:(NSIndexSet *)indices toPasteboard:(NSPasteboard *)pboard
{
	if ([indices count] > 1) {
		[[NSException exceptionWithName:@"PXIanIsLazyException" reason:@"Ian is too lazy to make dragging work with multiple selection!" userInfo:nil] raise];
		return;
	}
	if ([indices count] < 1) {
		return;
	}
	NSInteger index = [indices firstIndex];
	
	PXCel *cel = [self celAtIndex:index];
	
	NSBitmapImageRep *bitmapRep = [[cel canvas] imageRep];
	
	[pboard declareTypes:[NSArray arrayWithObjects:PXCelPboardType, NSTIFFPboardType, nil] owner:self];
	[pboard setData:[NSKeyedArchiver archivedDataWithRootObject:cel] forType:PXCelPboardType];
	[pboard setData:[bitmapRep TIFFRepresentation] forType:NSTIFFPboardType];
}

- (NSArray *)draggedTypesForFilmStripView:view
{
	return [[[NSArray arrayWithObject:PXCelPboardType] arrayByAddingObjectsFromArray:[NSImage imagePasteboardTypes]] arrayByAddingObject:NSFilenamesPboardType];
}

- (BOOL)insertCelIntoFilmStripView:view fromPasteboard:(NSPasteboard *)pboard atIndex:(NSInteger)targetDraggingIndex
{
	NSString *type = [pboard availableTypeFromArray:[self draggedTypesForFilmStripView:view]];
	if ([[NSImage imagePasteboardTypes] containsObject:type]) {
		NSImage *image = [[[NSImage alloc] initWithPasteboard:pboard] autorelease];
		NSImage *celImage;
		if (!NSEqualSizes([image size], [animation size])) {
			celImage = [[[NSImage alloc] initWithSize:[animation size]] autorelease];
			NSRect celImageRect = NSMakeRect(0, 0, [animation size].width, [animation size].height);
			NSRect destRect = celImageRect;
			if ([image size].width > [animation size].width || [image size].height > [animation size].height) {
				float imageAspectRatio = [image size].height / [image size].width;
				float celAspectRatio = [animation size].height / [animation size].width;
				if (imageAspectRatio > celAspectRatio) {
					destRect.size.width = NSHeight(destRect) / imageAspectRatio;
				} else {
					destRect.size.height = NSWidth(destRect) * imageAspectRatio;
				}
			} else {
				destRect.size = [image size];
			}
			destRect.origin.y = ([animation size].height - NSHeight(destRect)) / 2;
			destRect.origin.x = ([animation size].width - NSWidth(destRect)) / 2;
			[image setScalesWhenResized:YES];
			[image setSize:destRect.size];
			[celImage lockFocus];
			[[NSColor clearColor] set];
			NSRectFill(celImageRect);
			[image compositeToPoint:destRect.origin operation:NSCompositeCopy];
			NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:celImageRect];
			[celImage unlockFocus];
			[celImage removeRepresentation:[[celImage representations] objectAtIndex:0]];
			[celImage addRepresentation:bitmap];
            [bitmap release];

		} else {
			celImage = image;
		}
		
		PXCel *cel = [[[PXCel alloc] initWithImage:celImage animation:animation atIndex:targetDraggingIndex] autorelease];
		return (cel != nil);
	} else if ([type isEqualToString:PXCelPboardType]) {
		[animation insertObject:[NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:PXCelPboardType]] inCelsAtIndex:targetDraggingIndex];
		return YES;
	} else if ([type isEqualToString:NSFilenamesPboardType]) {
		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
		BOOL loadedSomething = NO;
		for (NSString *filename in [filenames sortedArrayUsingSelector:@selector(compareNumeric:)])
    {
			NSImage *image = [[[NSImage alloc] initWithContentsOfFile:filename] autorelease];
			if (image != nil) {
				PXCel *cel = [[[PXCel alloc] initWithImage:image animation:animation atIndex:targetDraggingIndex] autorelease];
				if (!loadedSomething) 
        {
					loadedSomething = (cel != nil);
				}
        targetDraggingIndex++;
			}
		}
		return loadedSomething;
	}
	return NO;
}

- (BOOL)copyCelInFilmStripView:view atIndex:(NSInteger)currentIndex toIndex:(NSInteger)anotherIndex
{
	[animation copyCelFromIndex:currentIndex toIndex:anotherIndex];
	[filmStrip setNeedsDisplay:YES];
	return YES;
}

- (IBAction)duplicateCel:sender
{
	NSInteger selectedIndex = [filmStrip selectedIndex];
	[animation copyCelFromIndex:selectedIndex toIndex:selectedIndex+1];
}

- (BOOL)moveCelInFilmStripView:view fromIndex:(NSInteger)index1 toIndex:(NSInteger)index2
{
	if((index1 == index2) || (index2 == (index1+1))) { return NO; }
	[animation moveCelFromIndex:index1 toIndex:index2];
	return YES;
}

- (id)celAtIndex:(NSUInteger)currentIndex
{
	return [animation celAtIndex:currentIndex];
}
- (NSTimeInterval)durationOfCelAtIndex:(NSUInteger)currentIndex
{
	return [[self celAtIndex:currentIndex] duration];	
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	//	[topSubview setMinDimension:oldMin andMaxDimension:oldMax];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	//oldMin = [topSubview minDimension];
	//oldMax = [topSubview maxDimension];
	//[topSubview setMinDimension:[topSubview dimension] andMaxDimension:[topSubview dimension]];
	return proposedFrameSize;
}

- (IBAction)newCel:(id)sender
{
	[self newCelButtonClicked:nil];
}

- (void)newCelButtonClicked:(id)sender
{
	NSInteger newIndex = [filmStrip selectedIndex] + 1;
	
	if (newIndex == NSNotFound) {
		newIndex = [animation countOfCels];
	}
	
	[animation insertNewCelAtIndex:newIndex];
	
	[[animation celAtIndex:newIndex] setDuration:[[animation celAtIndex:newIndex - 1] duration]];
}

- (void)filmStripSelectionDidChange:note
{
	[self activateCel:[filmStrip selectedCel]];
}

- (BOOL)canDeleteCel
{
	return [self numberOfCels] > 1;
}

- (void)deleteCelsAtIndices:(NSIndexSet *)indices
{
	if([animation countOfCels] <= 1) { return; }
	NSInteger currentIndex = [indices firstIndex];
	do
	{
		[animation removeCel:[self celAtIndex:currentIndex]];
	} while ((currentIndex = [indices indexGreaterThanIndex:currentIndex]) != NSNotFound);	
}

- (IBAction)deleteCel:sender
{
	[self deleteCelsAtIndices:[filmStrip selectedIndices]];
}

- (IBAction)selectPreviousCel:sender
{
	NSInteger newIndex = [filmStrip selectedIndex];
	if (newIndex == NSNotFound)
	{
		NSBeep();
		return;
	}
	newIndex--;
	if (newIndex < 0)
		newIndex = [self numberOfCels] - 1;
	[self activateCel:[self celAtIndex:newIndex]];
}

- (IBAction)selectNextCel:sender
{
	NSInteger newIndex = [filmStrip selectedIndex];
	if (newIndex == NSNotFound)
	{
		NSBeep();
		return;
	}
	newIndex++;
	if (newIndex >= [self numberOfCels])
		newIndex = 0;
	[self activateCel:[self celAtIndex:newIndex]];
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(createAnimationFromImage:))
		return NO;
	else if ([menuItem action] == @selector(selectPreviousCel:))
	{
		return ([self numberOfCels] > 1);
	}
	else if ([menuItem action] == @selector(selectNextCel:))
	{
		return ([self numberOfCels] > 1);
	}
	else if ([menuItem action] == @selector(deleteCel:))
	{
		return [self canDeleteCel];
	}
	else if ([menuItem action] == @selector(copyCel:))
	{
		return activeCel != nil;
	}
	else if ([menuItem action] == @selector(cutCel:))
	{
		return (activeCel != nil) && ([self numberOfCels] > 1);
	}
	else if ([menuItem action] == @selector(pasteCel:))
	{
		return ([[[NSPasteboard generalPasteboard] types] containsObject:PXCelPboardType]);
	}
	else if ([menuItem action] == @selector(toggleAutomaticPalette:))
	{
		return NO; // no restriction for animations
	}
	return [super validateMenuItem:menuItem];
}

- (void)exportSequencePrompterDidEnd:(PXSequenceExportPrompter *)prompter
{
	NSString *fileTemplate = [prompter fileTemplate];
	NSInteger i;
	NSInteger numberOfCels = [animation countOfCels];
	NSString *directoryPath = [[[prompter savePanel] URL] path];
	NSError *error = nil;
	
	if (![[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
								   withIntermediateDirectories:YES
													attributes:nil
														 error:&error]) {
		if (error)
			[self presentError:error];
		
		return;
	}
	
	for (i = 1; i <= numberOfCels; i++)
	{
		NSString *filePath = [[directoryPath copy] autorelease];
		
		if (![filePath hasSuffix:@"/"])
			filePath = [filePath stringByAppendingString:@"/"];
		
		NSString *finalTemplate = [fileTemplate stringByReplacingOccurrencesOfString:@"%f"
																		  withString:[NSString stringWithFormat:@"%d", i]];
		filePath = [filePath stringByAppendingString:finalTemplate];
		
		NSString *type = [prompter selectedUTI];
		PXCanvas *cnv = [[animation celAtIndex:i-1] canvas];
		
		NSData *data = [PXCanvasDocument dataRepresentationOfType:type withCanvas:cnv];
		[data writeToFile:filePath atomically:YES];
	}
}

- (IBAction)exportToImageSequence:sender
{
	PXSequenceExportPrompter *prompter = [[PXSequenceExportPrompter alloc] initWithDocument:[self document]];
	[prompter beginSheetModalForWindow:[self window] 
											 modalDelegate:self 
											didEndSelector:@selector(exportSequencePrompterDidEnd:)];
}

- (void)exportToQuicktimePrompterDidEnd:(NSSavePanel *)panel 
							 returnCode:(NSInteger)code 
							contextInfo:(void *)info
{
	if (code == NSFileHandlingPanelCancelButton)
		return;
	
	[panel orderOut:self];
	OSQTExporter *exporter = [[OSQTExporter alloc] init];
	NSInteger celCount = [animation countOfCels];
	NSInteger i;
	for (i = 0; i < celCount; i++)
	{
		[exporter addImage:[[animation celAtIndex:i] displayImage] 
				 forLength:[[animation celAtIndex:i] duration]];
	}
	
	[exporter exportToPath:[[panel URL] path] parentWindow:[self window]];
	[exporter release];
}

- (IBAction)exportToQuicktime:sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setNameFieldLabel:@"Export to:"];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mov"]];
	[savePanel setPrompt:@"Export"];
	
	[savePanel beginSheetModalForWindow:[self window]
					  completionHandler:^(NSInteger result) {
						  
						  [self exportToQuicktimePrompterDidEnd:savePanel
													 returnCode:result
													contextInfo:NULL];
						  
					  }];
}

- (void)scaleControllerDidFinish:(PXScaleController *)controller scale:(BOOL)scale
{
	if (scale)
	{
		PXCanvas *currentCanvas = [activeCel canvas];
		NSInteger celCount = [animation countOfCels];
		NSInteger i;
		for (i = 0; i < celCount; i++)
		{
			if ([[animation celAtIndex:i] canvas] == currentCanvas) { continue; }
			[self.scaleController scaleCanvas:[[animation celAtIndex:i] canvas]];
		}
	}
	[[[self document] undoManager] endUndoGrouping];
}

- (IBAction)scaleCanvas:(id) sender
{
	self.scaleController.delegate = self;
	
	[[[self document] undoManager] beginUndoGrouping];
	[super scaleCanvas:self];
}

- (void)canvasResizePrompter:(PXCanvasResizePrompter *)prompter didFinishWithSize:(NSSize)size
					position:(NSPoint)position backgroundColor:(NSColor *)color
{
	[animation setSize:size withOrigin:position backgroundColor:PXColorFromNSColor(color)];
}

- (IBAction)crop:sender
{
	NSRect selectedRect = [self.canvas selectedRect];
	[[[self document] undoManager] beginUndoGrouping];
	[animation setSize:selectedRect.size withOrigin:NSMakePoint(NSMinX(selectedRect) * -1, NSMinY(selectedRect) * -1) backgroundColor:PXGetClearColor()];
	[self.canvas deselect];
	[[[self document] undoManager] endUndoGrouping];
}

- (IBAction)copyCel:sender
{
	[self writeCelsAtIndices:[filmStrip selectedIndices] toPasteboard:[NSPasteboard generalPasteboard]];
}

- (IBAction)cutCel:sender
{
	[self copyCel:sender];
	[self deleteCel:sender];
}

- (IBAction)pasteCel:sender
{
	NSInteger newIndex = [filmStrip selectedIndex];
	if (newIndex == NSNotFound)
		newIndex = [self numberOfCels];
	else
		newIndex++;
	if (![self insertCelIntoFilmStripView:filmStrip fromPasteboard:[NSPasteboard generalPasteboard] atIndex:newIndex]) { return; }
}

- (IBAction)toggleAutomaticPalette:sender
{
	//noop
}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview {
	return (subview != self.canvasSplit) && (subview != topSubview);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	if (self.sidebarSplit == subview)
		return NO;
	
	if (topSubview == subview)
		return NO;
	
	return YES;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin
				 ofSubviewAt:(NSInteger)offset { 
	if(sender == self.splitView) {
		return 210;
	} else if(sender != outerSplitView) {
		return 110;
	}
	return [filmStrip minimumHeight];
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax 
				 ofSubviewAt:(NSInteger)offset {
	if(sender == self.splitView) {
		return 400;
	} else if(sender != outerSplitView) {
		return sender.frame.size.height-110;
	}
	return proposedMax;
}


@end
