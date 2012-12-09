//
//  PXCanvasWindowController_Toolbar.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasWindowController_Info.h"

@implementation PXCanvasWindowController(Info)

- (IBAction)nextInfoButtonTitle:(id)sender
{
    [self setInfoMode:[self infoMode] + 1];
    if ([self infoMode] > 2) {
        [self setInfoMode:0];
    }

    [self updateInfoButtonTitle];
}

- (void)updateInfoButtonTitle
{
    switch ([self infoMode]) {
        case PXCanvasInfoModeDimensions:
        {
            NSString *dimensions = [NSString stringWithFormat:@"%@ %@", [self width], [self height]];
            [[self infoButton] setTitle:dimensions];
            break;
        }
        case PXCanvasInfoModeDimensionsAndPosition:
        {
            NSString *dimensionsAndPositionString = [NSString stringWithFormat:@"%@ %@ %@ %@", [self width], [self height], [self cursorX], [self cursorY]];
            [[self infoButton] setTitle:dimensionsAndPositionString];
            break;
        }
        case PXCanvasInfoModeDimensionsAndPositionAndColor:
        {
            NSString *dimensionsAndPositionsAndColorString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@", [self width], [self height], [self cursorX], [self cursorY], [self red], [self green], [self blue], [self alpha], [self hex]];
            [[self infoButton] setTitle:dimensionsAndPositionsAndColorString];
            break;
        }
        default:
            break;
    }
    [[self infoButton] sizeToFit];
}

- (void)setCanvasSize:(NSSize)size
{
	[self setWidth:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"WIDTH_ABBR", @"Width"), (int)(size.width)]];
	[self setHeight:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"HEIGHT_ABBR", @"Height"), (int)(size.height)]];
    [self updateInfoButtonTitle];
}

- (void)setNoSize
{
	[self setWidth:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"WIDTH_ABBR", @"Width")]];
	[self setHeight:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"HEIGHT_ABBR", @"Height")]];
	[self setCursorX:@"X: --"];
	[self setCursorY:@"Y: --"];
    [self updateInfoButtonTitle];
}

- (void)draggingOriginChanged:(NSNotification *)notification
{
    [self setDraggingOrigin:[[[notification userInfo] valueForKey:@"draggingOrigin"] pointValue]];
    [self updateInfoButtonTitle];
}

- (void)cursorPositionChanged:(NSNotification *)notification
{
    NSPoint point = [[[notification userInfo] valueForKey:@"cursorPoint"] pointValue];
    NSPoint difference = point;
    difference.x -= [self draggingOrigin].x;
    difference.y -= [self draggingOrigin].y;

    if (difference.x > 0.1 || difference.x < -0.1) {
        [self setCursorX:[NSString stringWithFormat:@"X: %d (%@%d)", (int)(point.x), difference.x >= 0 ? @"+" : @"", (int)(difference.x)]];
    }
    else {
        [self setCursorX:[NSString stringWithFormat:@"X: %d", (int)(point.x)]];
    }

    if (difference.y > 0.1 || difference.y < -0.1) {
        [self setCursorY:[NSString stringWithFormat:@"Y: %d (%@%d)", (int)(point.y), difference.y >= 0 ? @"+" : @"", (int)(difference.y)]];
    }
    else {
        [self setCursorY:[NSString stringWithFormat:@"Y: %d", (int)(point.y)]];
    }
    [self updateInfoButtonTitle];
}

- (void)canvasColorChanged:(NSNotification *)notification
{
    PXColor color = PXColorFromNSColor([[notification userInfo] valueForKey:@"currentColor"]);
    [self setRed:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"RED_ABBR", @"Red"),     color.r]];
	[self setGreen:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"GREEN_ABBR", @"Green"), color.g]];
	[self setBlue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"BLUE_ABBR", @"Blue"),   color.b]];
	[self setAlpha:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"ALPHA_ABBR", @"Alpha"), color.a]];
	[self setHex:[NSString stringWithFormat:@"%@: #%02X%02X%02X", NSLocalizedString(@"Hex", @"Hex"), color.r, color.g, color.b]];
    [self updateInfoButtonTitle];
}

- (void)canvasNoColorChanged:(NSNotification *)notification
{
	[self setRed:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"RED_ABBR", @"Red")]];
	[self setGreen:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"GREEN_ABBR", @"Green")]];
	[self setBlue: [NSString stringWithFormat:@"%@: --", NSLocalizedString(@"BLUE_ABBR", @"Blue")]];
	[self setAlpha:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"ALPHA_ABBR", @"Alpha")]];
	[self setHex:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"Hex", @"Hex")]];
    [self updateInfoButtonTitle];
}

@end
