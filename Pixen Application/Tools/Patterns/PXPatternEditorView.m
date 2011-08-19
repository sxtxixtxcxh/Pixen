//
//  PXPatternEditorView.m
//  Pixen
//

#import "PXPatternEditorView.h"

#import "PXGrid.h"
#import "PXPattern.h"

@implementation PXPatternEditorView

@synthesize delegate;

#define SCALE_FACTOR 32.0f

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		grid = [[PXGrid alloc] initWithUnitSize:NSMakeSize(1.0f, 1.0f)
										  color:[NSColor grayColor]
									 shouldDraw:YES];
	}
	return self;
}

- (void)awakeFromNib
{
	[self registerForDraggedTypes:[NSArray arrayWithObject:PXPatternPboardType]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];
	[self setPattern:[NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:PXPatternPboardType]]];
	
	if ([delegate respondsToSelector:@selector(patternView:changedPattern:)])
		[delegate patternView:self changedPattern:pattern];
	
	return YES;
}

- (void)drawRect:(NSRect)rect
{
	if (pattern == nil)
		return;
	
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleBy:SCALE_FACTOR];
	[transform concat];
	[pattern drawRect:NSMakeRect(0.0f, 0.0f, [pattern size].width, [pattern size].height)];
	[grid drawRect:rect];
	[transform invert];
	[transform concat];
}

- (void)redrawPattern:(NSNotification *)notification
{
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
	if ([delegate respondsToSelector:@selector(patternView:changedPattern:)])
		[delegate patternView:self changedPattern:pattern];
}

- (void)mouseDown:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	point.x = floor(point.x / SCALE_FACTOR);
	point.y = floor(point.y / SCALE_FACTOR);
	
	[pattern togglePoint:point];
	erasing = ![pattern hasPixelAtPoint:point];
	
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	point.x = floor(point.x / SCALE_FACTOR);
	point.y = floor(point.y / SCALE_FACTOR);
	
	if (erasing) {
		[pattern removePoint:point];
	}
	else {
		[pattern addPoint:point];
	}
	
	[self setNeedsDisplay:YES];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[grid release];
	[super dealloc];
}
	
- (void)setPattern:(PXPattern *)newPattern
{
	if (pattern == newPattern)
		return;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	pattern = newPattern;
	[self setNeedsDisplay:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redrawPattern:)
												 name:PXPatternChangedNotificationName
											   object:pattern];
}

@end
