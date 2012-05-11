//
//  PXScaleController.m
//  Pixen
//

#import "PXScaleController.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Selection.h"
#import "PXCanvasWindowController.h"
#import "PXCanvasWindowController_IBActions.h"
#import "PXNearestNeighborScaleAlgorithm.h"
#import "PXScale2xScaleAlgorithm.h"
#import "PXQuartzScaleAlgorithm.h"

@implementation PXScaleController

static NSArray *algorithms = nil;

+ (void)initialize
{
	static BOOL ready = NO;
	if(!ready)
	{
		ready = YES;
		algorithms = [[NSArray alloc] initWithObjects:
			[PXNearestNeighborScaleAlgorithm algorithm], 
			[PXScale2xScaleAlgorithm algorithm], 
			[PXQuartzScaleAlgorithm algorithm],
			nil];
	}
}

- (id) init
{
	return self = [super initWithWindowNibName:@"PXScalePrompt"];
}

- (void)scaleCanvasFromController:(PXCanvasWindowController *)controller 
				   modalForWindow:(NSWindow *)theWindow
{
	canvasController = controller;
	if ([self isWindowLoaded]) 
    {
		newSize = [[canvasController canvas] size];
		[pixelsWideField setFloatValue:newSize.width];
		[pixelsHighField setFloatValue:newSize.height];
		[percentageWideField setFloatValue:100.0f];
		[percentageHighField setFloatValue:100.0f];
    }
	
	[NSApp beginSheet:[self window]
	   modalForWindow:theWindow
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[algorithmButton removeAllItems];
	
	for (PXScaleAlgorithm *algorithm in algorithms)
	{
		[algorithmButton addItemWithTitle:[algorithm name]];
	}
	
	if ([defaults objectForKey:PXSelectedScaleAlgorithmKey])
	{
		[algorithmButton selectItemWithTitle:[defaults objectForKey:PXSelectedScaleAlgorithmKey]];
	}
	
	[self setAlgorithm:algorithmButton];
	newSize = [[canvasController canvas] size];
	[self synchronizeForms:self];
}

- (PXScaleAlgorithm *)currentAlgorithm
{
	return [algorithms objectAtIndex:[algorithmButton indexOfSelectedItem]];
}

- (IBAction)setAlgorithm:(id) sender
{
	/*
	NSSize newBoxSize = [scaleParameterView frame].size;
	
	if ([[self currentAlgorithm] hasParameterView]) 
    {
		NSSize margins = [scaleParameterView contentViewMargins];
		newBoxSize.height = NSHeight([[[self currentAlgorithm] parameterView] frame]) + margins.height * 2;
    }
	else 
    {
		newBoxSize.height = 0;
    }
	
	NSRect newWindowFrame = [[self window] frame];
	newWindowFrame.size.height += newBoxSize.height - [scaleParameterView frame].size.height;
	if (![[self currentAlgorithm] hasParameterView] && lastAlgorithmHadParameterView) {
		newWindowFrame.size.height -= 8;
	}
	[[self window] setFrame:newWindowFrame display:YES animate:YES];
	
	if ([[self currentAlgorithm] hasParameterView]) {
		[scaleParameterView setContentView:[[self currentAlgorithm] parameterView]]; // Don't move this to the top of the method or it breaks.  No, I don't know why.
	}
	[scaleParameterView setFrameSize:newBoxSize];
	 */
	
	[algorithmInfoView setString:[[self currentAlgorithm] algorithmInfo]];
	
	[[NSUserDefaults standardUserDefaults] setObject:[[sender selectedItem] title] forKey:PXSelectedScaleAlgorithmKey];
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window]];
	[self close];
}

- (NSSize)directSizeInput
{
	NSSize oldSize = [[canvasController canvas] size];
	NSSize directSizeInput;
	float xScale = [percentageWideField floatValue] / 100.0f;
	float yScale = [percentageHighField floatValue] / 100.0f;
	
	directSizeInput.width = [pixelsWideField floatValue];
	
	if (fabs(oldSize.width * xScale - newSize.width) > .01) 
    {
		directSizeInput.width = oldSize.width * xScale;
    }
	
	directSizeInput.height = [pixelsHighField floatValue];
	
	if (fabs(oldSize.height * yScale - newSize.height) > .01) 
    {  
		directSizeInput.height = oldSize.height * yScale;
    }
	
	return directSizeInput;
}

- (IBAction)synchronizeForms:(id) sender
{
	NSSize oldSize = [[canvasController canvas] size];
	NSSize directSizeInput = [self directSizeInput];
	float xScale = [percentageWideField floatValue] / 100.0f;
	float yScale = [percentageHighField floatValue] / 100.0f;
	BOOL scaleProportionally = ([scaleProportionallyCheckbox state] == NSOnState);
	directSizeInput.width = [pixelsWideField floatValue];
	
	if (fabs(oldSize.width * xScale - newSize.width) > .01) {
		directSizeInput.width = oldSize.width * xScale;
	}
	
	directSizeInput.height = [pixelsHighField floatValue];
	
	if (fabs(oldSize.height * yScale - newSize.height) > .01) {
		directSizeInput.height = oldSize.height * yScale;
	}
	
	if (directSizeInput.width != 0 && directSizeInput.width != newSize.width) {
		if (scaleProportionally) {
			newSize.height = rintf(directSizeInput.width * oldSize.height / oldSize.width);
		} 
		else {
			newSize.height = directSizeInput.height;
		}
		newSize.width = directSizeInput.width;
	} 
	else if (directSizeInput.height != 0 && directSizeInput.height != newSize.height) {
		if (scaleProportionally) {
			newSize.width = rintf(directSizeInput.height * oldSize.width / oldSize.height);
		} else {
			newSize.width = directSizeInput.width;
		}
		newSize.height = directSizeInput.height;
	}
	
	if (newSize.width < 1) { // prevent making things 0 during proportional scaling
		newSize.width = 1;
	}
	if (newSize.height < 1) {
		newSize.height = 1;
	}
	[pixelsWideField setFloatValue:newSize.width];
	[pixelsHighField setFloatValue:newSize.height];
	[percentageWideField setFloatValue:newSize.width / oldSize.width * 100.0f];
	[percentageHighField setFloatValue:newSize.height / oldSize.height * 100.0f];
}

- (IBAction)updateToScalePropotionally:(id) sender
{
	if ([sender state] != NSOnState) 
		return;
	
	else 
    {
		NSSize directSizeInput = [self directSizeInput];
		NSSize oldSize = [[canvasController canvas] size];
		newSize.width = directSizeInput.height * oldSize.width / oldSize.height;
		newSize.height = directSizeInput.height;
		[self synchronizeForms:sender];
    }
}

- (void)scaleCanvas:(PXCanvas *)canvas
{
	[canvas beginUndoGrouping]; {
//FIXME: move undo
	// Do we really have to deselect when we change size? We can't adapt?
	// Ohhhh, the memory cost. The pain.

	PXSelectionMask oldMask = malloc([canvas selectionMaskSize]);
	memcpy(oldMask, [canvas selectionMask], [canvas selectionMaskSize]);
	PXSelectionMask newMask = (PXSelectionMask)calloc(newSize.width * newSize.height, sizeof(BOOL));
	[canvas setLayers:[[[canvas layers] deepMutableCopy] autorelease]
		   fromLayers:[canvas layers]
	  withDescription:NSLocalizedString(@"Set Layers", @"Set Layers")];
	//this seems wrong.  you'd think we'd want to use the actual old canvas size, but whatever...
	NSData *oldMaskData = [NSData dataWithBytesNoCopy:oldMask length:[canvas selectionMaskSize]];
	NSData *newMaskData = [NSData dataWithBytesNoCopy:newMask length:newSize.width * newSize.height * sizeof(BOOL)];
	[canvas setMaskData:newMaskData withOldMaskData:oldMaskData];
	[[self currentAlgorithm] scaleCanvas:[canvasController canvas] 
								  toSize:newSize];
	[canvas setHasSelection:NO];
	
	} [canvas endUndoGrouping:NSLocalizedString(@"Scale Canvas", @"Scale Canvas")];	
}

- (IBAction)scale:(id) sender
{
	[self synchronizeForms:nil];
	
	if ( [[self currentAlgorithm] canScaleCanvas:[canvasController canvas] 
										  toSize:newSize]) 
    {
		[self scaleCanvas:[canvasController canvas]];
		[canvasController updateCanvasSize];
		[NSApp endSheet:[self window]];
		[self close];
    } 
	else 
    {
		NSBeep();
    }
	
	if (delegate)
	{
		[delegate performSelector:callback withObject:self withObject:[NSNumber numberWithBool:[[self currentAlgorithm] canScaleCanvas:[canvasController canvas] toSize:newSize]]];
	}
	delegate = nil;
	callback = NULL;
}

- (void)setDelegate:aDelegate withCallback:(SEL)aCallback
{
	delegate = aDelegate;
	callback = aCallback;
}

@end
