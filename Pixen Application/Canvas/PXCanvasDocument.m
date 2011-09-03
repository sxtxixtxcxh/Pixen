//
//  PXCanvasDocument.m
//  Pixen
//

#import "PXCanvasDocument.h"
#import "PXCanvasWindowController.h"
#import "PXCanvas.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_CopyPaste.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "PXPalette.h"
#import "PXCanvasView.h"
#import "PXCanvasPrintView.h"
#import "PXLayerController.h"
#import "PXIconExporter.h"
#import "gif_lib.h"
#import "PXAnimatedGifExporter.h"
#import "PXLayer.h"
#import <AppKit/NSAlert.h>
#import "PXCanvasWindowController_IBActions.h"

BOOL isPowerOfTwo(int num);

@implementation PXCanvasDocument

- (id)init
{
	if ( ! ( self = [super init] ) ) 
		return nil;
	
	canvas = [[PXCanvas alloc] init];
	[canvas setUndoManager:[self undoManager]];
	[[self undoManager] removeAllActions];
	[self updateChangeCount:NSChangeCleared]; 
  return self;
}

- (void)setCanvas:(PXCanvas *)aCanvas
{
	[aCanvas retain];
	[canvas release];
	canvas = aCanvas;
	[canvas setUndoManager:[self undoManager]];
}

- (void)dealloc
{
	[self.windowController releaseCanvas];
	[canvas release];
	//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (PXCanvasController *)canvasController
{
	return [self.windowController canvasController];
}

- (void)initWindowController
{
	self.windowController = [[[PXCanvasWindowController alloc] initWithWindowNibName:@"PXCanvasDocument"] autorelease];
}

- (void)setWindowControllerData
{
	[self.windowController setCanvas:canvas];
}

BOOL isPowerOfTwo(int num)
{
	double logResult = log2(num);
	return (logResult == (int)logResult);
}

- (void)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
  if(absoluteURL == nil)
  {
    return;
  }
  if (UTTypeEqual(kUTTypeJPEG, (__bridge CFStringRef) typeName))
	{
		saveFactor = 100;
  }
  [super saveToURL:absoluteURL 
            ofType:typeName 
  forSaveOperation:saveOperation 
          delegate:delegate 
   didSaveSelector:didSaveSelector 
       contextInfo:contextInfo];
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel
{
	NSString *lastType = [[NSUserDefaults standardUserDefaults] stringForKey:PXLastSavedFileType];
	
	if (!lastType)
		lastType = PixenImageFileType;
	
	NSView *accessoryView = [savePanel accessoryView];
	NSPopUpButton *popUpButton = nil;
	
	if ([[accessoryView subviews] count]) {
		NSView *box = [[accessoryView subviews] objectAtIndex:0];
		
		if ([[box subviews] count]) {
			for (NSView *view in [box subviews]) {
				if ([view isKindOfClass:[NSPopUpButton class]]) {
					popUpButton = (NSPopUpButton *) view;
					break;
				}
			}
		}
	}
	
	if (popUpButton) {
		NSString *name = (NSString *) UTTypeCopyDescription((__bridge CFStringRef)lastType);
		[popUpButton selectItemWithTitle:name];
		[name release];
	}
	
	return YES;
}

+ (NSData *)dataRepresentationOfType:(NSString *)aType withCanvas:(PXCanvas *)canvas
{
	if([aType isEqualToString:PixenImageFileType] ||
		 [aType isEqualToString:PixenImageFileTypeOld])
  {
		return [NSKeyedArchiver archivedDataWithRootObject:canvas];
  }
	
	if (UTTypeEqual(kUTTypeJPEG, (__bridge CFStringRef) aType))
	{
		return [canvas imageDataWithType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                                                           forKey:NSImageCompressionFactor]];
	}
  
	if (UTTypeEqual(kUTTypeICO, (__bridge CFStringRef) aType))
	{
		PXIconExporter *iconExporter = [[[PXIconExporter alloc] init] autorelease];
		return [iconExporter iconDataForCanvas:canvas];
	}
	
	if(UTTypeEqual(kUTTypePNG, (__bridge CFStringRef) aType))
  {
		return [canvas imageDataWithType:NSPNGFileType properties:nil];
  }
	
	if(UTTypeEqual(kUTTypeTIFF, (__bridge CFStringRef) aType))
  {
		return [canvas imageDataWithType:NSTIFFFileType properties:nil];
  }
	
	
	if (UTTypeEqual(kUTTypeGIF, (__bridge CFStringRef) aType))
	{
		PXCanvas *exportCanvas = [canvas copy];
		[exportCanvas reduceColorsTo:256 withTransparency:YES matteColor:[NSColor whiteColor]];
		
		PXAnimatedGifExporter *exporter = [[PXAnimatedGifExporter alloc] initWithSize:[canvas size] iterations:1];
		[exporter writeCanvas:exportCanvas withDuration:0 transparentColor:nil];
		[exporter finalizeExport];
		[exportCanvas release];
		
		NSData *data = [[exporter data] retain];
		[exporter release];
		
		return [data autorelease];
		//return [PXGifExporter gifDataForImage:[canvas exportImage]];
	}
	
	if(UTTypeEqual(kUTTypeBMP, (__bridge CFStringRef) aType))
  {
		return [canvas imageDataWithType:NSBMPFileType properties:nil];
  }
	if(UTTypeEqual(kUTTypePICT, (__bridge CFStringRef) aType))
	{
		NSMutableData *pictData = [NSMutableData data];
		CGImageDestinationRef pictOutput = 
		CGImageDestinationCreateWithData((__bridge CFMutableDataRef)pictData, 
										 kUTTypePICT, 
										 1, 
										 NULL);
		CGImageDestinationAddImage(pictOutput,
								   [[canvas displayImage] CGImageForProposedRect:NULL 
																		 context:nil 
																		   hints:nil],
								   NULL);
		CGImageDestinationFinalize(pictOutput);
		CFRelease(pictOutput);
		return pictData;
	}
	
	return nil;
}

- (NSData *)dataOfType:(NSString *)type error:(NSError **)err
{
	[[NSUserDefaults standardUserDefaults] setObject:type forKey:PXLastSavedFileType];
	
	if (UTTypeEqual(kUTTypeJPEG, (__bridge CFStringRef) type))
	{
    NSNumber *sf = [NSNumber numberWithFloat:saveFactor];
    NSDictionary *props = [NSDictionary dictionaryWithObject:sf
                                                      forKey:NSImageCompressionFactor];
		return [canvas imageDataWithType:NSJPEGFileType 
                          properties:props];
	}
	return [[self class] dataRepresentationOfType:type withCanvas:canvas];
}

- (void)loadFromPasteboard:(NSPasteboard *)board
{	
	if ([[board types] containsObject:PXLayerPboardType])
	{
    NSData *data = [board dataForType:PXLayerPboardType];
		PXLayer *layer = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		[canvas setSize:[layer size]];
		[canvas pasteFromPasteboard:board type:PXLayerPboardType];
	}
	else 
	{
		for (NSString *type in [NSImage imagePasteboardTypes])
		{
			if ([[board types] containsObject:type])
			{
				NSImage *image = [[[NSImage alloc] initWithPasteboard:board] autorelease];
				[canvas setSize:NSMakeSize(ceilf([image size].width), 
                                   ceilf([image size].height))];
				[canvas pasteFromPasteboard:board type:PXNSImagePboardType];
				break;
			}
		}
	}
	
	if (canvas)
	{
		[canvas setUndoManager:[self undoManager]];
		[self makeWindowControllers];
		// remove the auto-created main layer
		if ([[canvas layers] count] > 1)
    {
			[canvas removeLayerAtIndex:0];
    }
	}
	
	[[self undoManager] removeAllActions];
	[self updateChangeCount:NSChangeCleared];
}

- (void)delete:(id)sender
{
	[self.windowController delete:sender];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)aType error:(NSError **)error
{
	if (UTTypeEqual( (__bridge CFStringRef) aType, (__bridge CFStringRef) PixenImageFileType) ||
		UTTypeEqual( (__bridge CFStringRef) aType, (__bridge CFStringRef) PixenImageFileTypeOld))
	{
		[canvas release];
		canvas = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
	}
	else if (UTTypeEqual(kUTTypeBMP, (__bridge CFStringRef) aType))
	{
		[canvas release];
		canvas = [[PXCanvas alloc] init];
		[canvas replaceActiveLayerWithImage:[[[NSImage alloc] initWithData:data] autorelease]];
	}
	else
	{
		NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
		
		if (!image) {
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:nil];
			return NO;
		}
		
		[canvas release];
		canvas = [[PXCanvas alloc] initWithImage:image];
	}
	
	if (canvas)
	{
		[canvas setUndoManager:[self undoManager]];
		[self.windowController setCanvas:canvas];
		[[self undoManager] removeAllActions];
		[self updateChangeCount:NSChangeCleared]; 
		return YES;
	}
	
	return NO;
}

- (void)printDocumentWithSettings:(NSDictionary *)printSettings
				   showPrintPanel:(BOOL)showPanels delegate:(id)delegate
				 didPrintSelector:(SEL)didPrintSelector contextInfo:(void *)contextInfo {
	
	if (!printableView) {
		printableView = [PXCanvasPrintView viewForCanvas:[self canvas]];
		[printableView retain];
	}
	
	float scale = [[[[self printInfo] dictionary] objectForKey:NSPrintScalingFactor] floatValue];
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleXBy:scale yBy:scale];
	
	[printableView setBoundsOrigin:[transform transformPoint:[printableView frame].origin]];
	[printableView setBoundsSize:[transform transformSize:[printableView frame].size]];
	
	NSPrintOperation *op = [NSPrintOperation printOperationWithView:printableView
														  printInfo:[self printInfo]];
	[op setShowsPrintPanel:showPanels];
	[op setShowsProgressPanel:showPanels];
	
	[self runModalPrintOperation:op delegate:nil didRunSelector:NULL contextInfo:NULL];
}

-(PXCanvas *)canvas
{
	return canvas;
}

@end