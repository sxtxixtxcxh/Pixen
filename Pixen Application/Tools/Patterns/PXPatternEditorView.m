//
//  PXPatternEditorView.m
//  Pixen
//

#import "PXPatternEditorView.h"
#import "PXPattern.h"
#import "PXGrid.h"
#import "InterpolatePoint.h"


@implementation PXPatternEditorView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		grid = [[PXGrid alloc] initWithUnitSize:NSMakeSize(1,1) color:[NSColor grayColor] shouldDraw:YES];
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
	[delegate patternView:self changedPattern:pattern];
	return YES;
}

- (void)drawRect:(NSRect)rect {
	if (pattern == nil)
		return;
	
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleBy:32];
	[transform concat];
	[pattern drawRect:NSMakeRect(0.0f, 0.0f, [pattern size].width, [pattern size].height)];
//	[grid drawRect:rect];
	[transform invert];
	[transform concat];
}

- (void)redrawPattern:(NSNotification *)notification
{
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
	[delegate patternView:self changedPattern:pattern];
}

- (void)mouseDown:(NSEvent *)event
{
//	initialPoint = [self convertFromWindowToPatternPoint:[event locationInWindow]];
	
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	point.x = floor(point.x / 32);
	point.y = floor(point.y / 32);
	
	[pattern togglePoint:point];
	erasing = ![pattern hasPixelAtPoint:initialPoint];
	
	[self setNeedsDisplay:YES];
}

/*
- (void)mouseDragged:(NSEvent *)event
{
//	NSPoint finalPoint = [self convertFromWindowToPatternPoint:[event locationInWindow]];
	NSPoint differencePoint = NSMakePoint(finalPoint.x - initialPoint.x, finalPoint.y - initialPoint.y);
    NSPoint currentPoint = initialPoint;
    while(!NSEqualPoints(finalPoint, currentPoint))
    {
		currentPoint = InterpolatePointFromPointByPoint(currentPoint, initialPoint, differencePoint);		
		if (erasing) {
			[pattern removePoint:currentPoint];
		} else {
			[pattern addPoint:currentPoint];
		}
    }
	initialPoint = finalPoint;
}
*/

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[grid release];
	[super dealloc];
}
	
- (void)setPattern:(PXPattern *)newPattern
{
	if (pattern == newPattern) {
		return;
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	pattern = newPattern;
	[self setNeedsDisplay:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawPattern:) name:PXPatternChangedNotificationName object:pattern];
}

@end
