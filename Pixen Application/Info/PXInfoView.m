//
//  PXInfoView.m
//  Pixen
//
//  Copyright 2013 Pixen Project. All rights reserved.
//

#import "PXInfoView.h"

#import "PXSeparatorView.h"

typedef NS_ENUM(NSUInteger, PXCanvasInfoMode) {
    PXCanvasInfoModeDimensions,
    PXCanvasInfoModeDimensionsAndPosition,
    PXCanvasInfoModeDimensionsAndPositionAndColor
};


@interface PXInfoView ()

@property (nonatomic, assign) PXCanvasInfoMode infoMode;

@end


@implementation PXInfoView {
	NSTextField *_widthL;
	NSTextField *_heightL;
	NSTextField *_widthF;
	NSTextField *_heightF;
	
	PXSeparatorView *_sv1;
	
	NSTextField *_xL;
	NSTextField *_xF;
	NSTextField *_yL;
	NSTextField *_yF;
	
	PXSeparatorView *_sv2;
	
	NSTextField *_rL;
	NSTextField *_rF;
	NSTextField *_gL;
	NSTextField *_gF;
	NSTextField *_bL;
	NSTextField *_bF;
	NSTextField *_aL;
	NSTextField *_aF;
}

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self) {
		_infoMode = PXCanvasInfoModeDimensionsAndPositionAndColor;
		
		[self addSubview:[self widthLabel]];
		[self addSubview:[self widthField]];
		
		[self addSubview:[self heightLabel]];
		[self addSubview:[self heightField]];
		
		[self addSubview:[self sv1]];
		
		[self addSubview:[self xLabel]];
		[self addSubview:[self xField]];
		
		[self addSubview:[self yLabel]];
		[self addSubview:[self yField]];
		
		[self addSubview:[self sv2]];
		
		[self addSubview:[self rLabel]];
		[self addSubview:[self rField]];
		
		[self addSubview:[self gLabel]];
		[self addSubview:[self gField]];
		
		[self addSubview:[self bLabel]];
		[self addSubview:[self bField]];
		
		[self addSubview:[self aLabel]];
		[self addSubview:[self aField]];
	}
	return self;
}

+ (NSArray *)restorableStateKeyPaths {
	return @[ @"infoMode" ];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeInteger:self.infoMode forKey:@"infoMode"];
}

- (void)restoreStateWithCoder:(NSCoder *)coder {
	[super restoreStateWithCoder:coder];
	
	self.infoMode = [coder decodeIntegerForKey:@"infoMode"];
}

- (void)setInfoMode:(PXCanvasInfoMode)infoMode {
	if (_infoMode != infoMode) {
		_infoMode = infoMode;
		
		[self displayInfoMode];
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	self.infoMode++;
	
	if (self.infoMode > 2)
		self.infoMode = 0;
}

- (void)displayInfoMode {
	[self layoutLabels];
}

- (PXSeparatorView *)sv1 {
	if (!_sv1) {
		_sv1 = [[PXSeparatorView alloc] initWithFrame:NSZeroRect];
	}
	
	return _sv1;
}

- (PXSeparatorView *)sv2 {
	if (!_sv2) {
		_sv2 = [[PXSeparatorView alloc] initWithFrame:NSZeroRect];
	}
	
	return _sv2;
}

- (NSTextField *)newLabel {
	NSTextField *label = [[NSTextField alloc] initWithFrame:NSZeroRect];
	[[label cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[label setTextColor:[NSColor colorWithCalibratedWhite:0.4f alpha:1.0f]];
	[label setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
	[label setBezeled:NO];
	[label setDrawsBackground:NO];
	[label setEditable:NO];
	
	return label;
}

- (NSTextField *)newField {
	NSTextField *field = [[NSTextField alloc] initWithFrame:NSZeroRect];
	[[field cell] setBackgroundStyle:NSBackgroundStyleRaised];
	[field setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
	[field setBezeled:NO];
	[field setDrawsBackground:NO];
	[field setEditable:NO];
	
	return field;
}

- (NSTextField *)widthLabel {
	if (!_widthL) {
		_widthL = [self newLabel];
		[_widthL setStringValue:@"W:"];
		[_widthL sizeToFit];
	}
	
	return _widthL;
}

- (NSTextField *)heightLabel {
	if (!_heightL) {
		_heightL = [self newLabel];
		[_heightL setStringValue:@"H:"];
		[_heightL sizeToFit];
	}
	
	return _heightL;
}

- (NSTextField *)widthField {
	if (!_widthF) {
		_widthF = [self newField];
	}
	
	return _widthF;
}

- (NSTextField *)heightField {
	if (!_heightF) {
		_heightF = [self newField];
	}
	
	return _heightF;
}

- (NSTextField *)xLabel {
	if (!_xL) {
		_xL = [self newLabel];
		[_xL setStringValue:@"X:"];
		[_xL sizeToFit];
	}
	
	return _xL;
}

- (NSTextField *)yLabel {
	if (!_yL) {
		_yL = [self newLabel];
		[_yL setStringValue:@"Y:"];
		[_yL sizeToFit];
	}
	
	return _yL;
}

- (NSTextField *)xField {
	if (!_xF) {
		_xF = [self newField];
	}
	
	return _xF;
}

- (NSTextField *)yField {
	if (!_yF) {
		_yF = [self newField];
	}
	
	return _yF;
}

- (NSTextField *)rLabel {
	if (!_rL) {
		_rL = [self newLabel];
		[_rL setStringValue:@"R:"];
		[_rL sizeToFit];
	}
	
	return _rL;
}

- (NSTextField *)rField {
	if (!_rF) {
		_rF = [self newField];
	}
	
	return _rF;
}

- (NSTextField *)gLabel {
	if (!_gL) {
		_gL = [self newLabel];
		[_gL setStringValue:@"G:"];
		[_gL sizeToFit];
	}
	
	return _gL;
}

- (NSTextField *)gField {
	if (!_gF) {
		_gF = [self newField];
	}
	
	return _gF;
}

- (NSTextField *)bLabel {
	if (!_bL) {
		_bL = [self newLabel];
		[_bL setStringValue:@"B:"];
		[_bL sizeToFit];
	}
	
	return _bL;
}

- (NSTextField *)bField {
	if (!_bF) {
		_bF = [self newField];
	}
	
	return _bF;
}

- (NSTextField *)aLabel {
	if (!_aL) {
		_aL = [self newLabel];
		[_aL setStringValue:@"A:"];
		[_aL sizeToFit];
	}
	
	return _aL;
}

- (NSTextField *)aField {
	if (!_aF) {
		_aF = [self newField];
	}
	
	return _aF;
}

- (void)setWidth:(NSInteger)width {
	if (_width != width) {
		_width = width;
		
		[_widthF setStringValue:[NSString stringWithFormat:@"%ld", _width]];
		[_widthF sizeToFit];
		
		[self layoutLabels];
	}
}

- (void)setHeight:(NSInteger)height {
	if (_height != height) {
		_height = height;
		
		[_heightF setStringValue:[NSString stringWithFormat:@"%ld", _height]];
		[_heightF sizeToFit];
		
		[self layoutLabels];
	}
}

- (void)updateCoords {
	if (_cursorX < 0 || _cursorX >= _width || _cursorY < 0 || _cursorY >= _height) {
		[_xF setStringValue:@"-"];
		[_yF setStringValue:@"-"];
	}
	else {
		[_xF setStringValue:[NSString stringWithFormat:@"%ld", _cursorX]];
		[_yF setStringValue:[NSString stringWithFormat:@"%ld", _cursorY]];
	}
	
	[_xF sizeToFit];
	[_yF sizeToFit];
}

- (void)setCursorX:(NSInteger)cursorX {
	if (_cursorX != cursorX) {
		_cursorX = cursorX;
		
		[self updateCoords];
		[self layoutLabels];
	}
}

- (void)setCursorY:(NSInteger)cursorY {
	if (_cursorY != cursorY) {
		_cursorY = cursorY;
		
		[self updateCoords];
		[self layoutLabels];
	}
}

- (void)updateColor {
	if (_hasColor) {
		[_rF setStringValue:[NSString stringWithFormat:@"%d", _color.r]];
		[_gF setStringValue:[NSString stringWithFormat:@"%d", _color.g]];
		[_bF setStringValue:[NSString stringWithFormat:@"%d", _color.b]];
		[_aF setStringValue:[NSString stringWithFormat:@"%d", _color.a]];
	}
	else {
		[_rF setStringValue:@"-"];
		[_gF setStringValue:@"-"];
		[_bF setStringValue:@"-"];
		[_aF setStringValue:@"-"];
	}
	
	[_rF sizeToFit];
	[_gF sizeToFit];
	[_bF sizeToFit];
	[_aF sizeToFit];
}

- (void)setColor:(PXColor)color {
	_color = color;
	
	[self updateColor];
	[self layoutLabels];
}

- (void)setHasColor:(BOOL)hasColor {
	if (_hasColor != hasColor) {
		_hasColor = hasColor;
		
		[self updateColor];
		[self layoutLabels];
	}
}

- (CGFloat)widthForDigits:(NSUInteger)count {
	NSMutableString *str = [[NSMutableString alloc] init];
	
	for (NSUInteger n = 0; n < count; n++) {
		[str appendString:@"9"];
	}
	
	NSDictionary *attrs = @{NSFontAttributeName : [NSFont systemFontOfSize:[NSFont smallSystemFontSize]]};
	
	return [str boundingRectWithSize:NSMakeSize(SIZE_MAX, SIZE_MAX) options:0 attributes:attrs].size.width + 6.0f;
}

- (void)layoutLabels {
	if (self.infoMode == PXCanvasInfoModeDimensions) {
		[_sv1 setHidden:YES];
		[_sv2 setHidden:YES];
		
		[_xL setHidden:YES];
		[_xF setHidden:YES];
		[_yL setHidden:YES];
		[_yF setHidden:YES];
		
		[_rL setHidden:YES];
		[_rF setHidden:YES];
		[_gL setHidden:YES];
		[_gF setHidden:YES];
		[_bL setHidden:YES];
		[_bF setHidden:YES];
		[_aL setHidden:YES];
		[_aF setHidden:YES];
	}
	else if (self.infoMode == PXCanvasInfoModeDimensionsAndPosition) {
		[_sv1 setHidden:NO];
		[_sv2 setHidden:YES];
		
		[_xL setHidden:NO];
		[_xF setHidden:NO];
		[_yL setHidden:NO];
		[_yF setHidden:NO];
		
		[_rL setHidden:YES];
		[_rF setHidden:YES];
		[_gL setHidden:YES];
		[_gF setHidden:YES];
		[_bL setHidden:YES];
		[_bF setHidden:YES];
		[_aL setHidden:YES];
		[_aF setHidden:YES];
	}
	else if (self.infoMode == PXCanvasInfoModeDimensionsAndPositionAndColor) {
		[_sv1 setHidden:NO];
		[_sv2 setHidden:NO];
		
		[_xL setHidden:NO];
		[_xF setHidden:NO];
		[_yL setHidden:NO];
		[_yF setHidden:NO];
		
		[_rL setHidden:NO];
		[_rF setHidden:NO];
		[_gL setHidden:NO];
		[_gF setHidden:NO];
		[_bL setHidden:NO];
		[_bF setHidden:NO];
		[_aL setHidden:NO];
		[_aF setHidden:NO];
	}
	
	NSRect r;
	
	r = _widthL.frame;
	r.origin.x = 0.0f;
	_widthL.frame = r;
	
	r = _widthF.frame;
	r.origin.x = NSMaxX(_widthL.frame);
	_widthF.frame = r;
	
	r = _heightL.frame;
	r.origin.x = NSMaxX(_widthF.frame) + 4.0f;
	_heightL.frame = r;
	
	r = _heightF.frame;
	r.origin.x = NSMaxX(_heightL.frame);
	_heightF.frame = r;
	
	_sv1.frame = NSMakeRect(NSMaxX(_heightF.frame) + 7.0f, 0.0f, 1.0f, 14.0f);
	
	r = _xL.frame;
	r.origin.x = NSMaxX(_heightF.frame) + 16.0f;
	_xL.frame = r;
	
	r = _xF.frame;
	r.origin.x = NSMaxX(_xL.frame);
	r.size.width = NSWidth(_widthF.frame);
	_xF.frame = r;
	
	r = _yL.frame;
	r.origin.x = NSMaxX(_xF.frame) + 4.0f;
	_yL.frame = r;
	
	r = _yF.frame;
	r.origin.x = NSMaxX(_yL.frame);
	r.size.width = NSWidth(_heightF.frame);
	_yF.frame = r;
	
	_sv2.frame = NSMakeRect(NSMaxX(_yF.frame) + 7.0f, 0.0f, 1.0f, 14.0f);
	
	r = _rL.frame;
	r.origin.x = NSMaxX(_yF.frame) + 16.0f;
	_rL.frame = r;
	
	r = _rF.frame;
	r.origin.x = NSMaxX(_rL.frame);
	r.size.width = [self widthForDigits:3];
	_rF.frame = r;
	
	r = _gL.frame;
	r.origin.x = NSMaxX(_rF.frame) + 4.0f;
	_gL.frame = r;
	
	r = _gF.frame;
	r.origin.x = NSMaxX(_gL.frame);
	r.size.width = [self widthForDigits:3];
	_gF.frame = r;
	
	r = _bL.frame;
	r.origin.x = NSMaxX(_gF.frame) + 4.0f;
	_bL.frame = r;
	
	r = _bF.frame;
	r.origin.x = NSMaxX(_bL.frame);
	r.size.width = [self widthForDigits:3];
	_bF.frame = r;
	
	r = _aL.frame;
	r.origin.x = NSMaxX(_bF.frame) + 4.0f;
	_aL.frame = r;
	
	r = _aF.frame;
	r.origin.x = NSMaxX(_aL.frame);
	r.size.width = [self widthForDigits:3];
	_aF.frame = r;
	
	if ([self bounds].size.width < NSMaxX(_aF.frame)) {
		[_sv2 setHidden:YES];
		
		[_rL setHidden:YES];
		[_rF setHidden:YES];
		[_gL setHidden:YES];
		[_gF setHidden:YES];
		[_bL setHidden:YES];
		[_bF setHidden:YES];
		[_aL setHidden:YES];
		[_aF setHidden:YES];
	}
	
	if ([self bounds].size.width < NSMaxX(_yF.frame)) {
		[_sv1 setHidden:YES];
		
		[_xL setHidden:YES];
		[_xF setHidden:YES];
		[_yL setHidden:YES];
		[_yF setHidden:YES];
	}
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize {
	[super resizeWithOldSuperviewSize:oldSize];
	
	[self layoutLabels];
}

@end
