//
//  PXPatternEditorView.m
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

#import "PXPatternEditorView.h"

#import "PXGrid.h"
#import "PXPattern.h"

@implementation PXPatternEditorView

@synthesize pattern = _pattern;
@synthesize delegate = _delegate;

#define SCALE_FACTOR 32.0f

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_grid = [[PXGrid alloc] initWithUnitSize:NSMakeSize(1.0f, 1.0f)
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
	
	if ([_delegate respondsToSelector:@selector(patternView:changedPattern:)])
		[_delegate patternView:self changedPattern:_pattern];
	
	return YES;
}

- (void)drawRect:(NSRect)rect
{
	if (_pattern == nil)
		return;
	
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleBy:SCALE_FACTOR];
	[transform concat];
	
	[_pattern drawRect:NSMakeRect(0.0f, 0.0f, [_pattern size].width, [_pattern size].height)];
	[_grid drawRect:rect];
	
	[transform invert];
	[transform concat];
}

- (void)redrawPattern:(NSNotification *)notification
{
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
	if ([_delegate respondsToSelector:@selector(patternView:changedPattern:)])
		[_delegate patternView:self changedPattern:_pattern];
}

- (void)mouseDown:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	point.x = floor(point.x / SCALE_FACTOR);
	point.y = floor(point.y / SCALE_FACTOR);
	
	[_pattern togglePoint:point];
	_erasing = ![_pattern hasPixelAtPoint:point];
	
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event
{
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	point.x = floor(point.x / SCALE_FACTOR);
	point.y = floor(point.y / SCALE_FACTOR);
	
	if (_erasing) {
		[_pattern removePoint:point];
	}
	else {
		[_pattern addPoint:point];
	}
	
	[self setNeedsDisplay:YES];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_grid release];
	[super dealloc];
}

- (void)setPattern:(PXPattern *)newPattern
{
	if (_pattern == newPattern)
		return;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	_pattern = newPattern;
	[self setNeedsDisplay:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redrawPattern:)
												 name:PXPatternChangedNotificationName
											   object:_pattern];
}

@end
