//
//  PXInfoPanelController.h
//  Pixen
//

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

#import <AppKit/NSNibDeclarations.h>

@class NSColor;
@class NSPanel;
@class NSTextField;

@interface PXInfoPanelController : NSObject
{
  @private
	NSPoint draggingOrigin;
		
	IBOutlet NSPanel *panel;
	
	IBOutlet NSTextField *cursorX;
	IBOutlet NSTextField *cursorY;
	IBOutlet NSTextField *width;
	IBOutlet NSTextField *height;
	IBOutlet NSTextField *red;
	IBOutlet NSTextField *green;
	IBOutlet NSTextField *blue;
	IBOutlet NSTextField *alpha;
	IBOutlet NSTextField *hex;
}

//singleton
+ (id) sharedInfoPanelController;

- (void)setCursorPosition: (NSPoint)point;
- (void)setColorInfo:(NSColor *) color;
- (void)setCanvasSize: (NSSize)size;
- (void)setDraggingOrigin: (NSPoint)point;

	//Accessor
- (NSPanel *) infoPanel;

@end
