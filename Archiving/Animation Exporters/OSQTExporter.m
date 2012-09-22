//
//  OSQTExporter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "OSQTExporter.h"
#import "OSProgressPopup.h"

#import <AVFoundation/AVFoundation.h>

@implementation OSQTExporter {
	AVAssetWriter *_videoWriter;
	AVAssetWriterInput *_writerInput;
	AVAssetWriterInputPixelBufferAdaptor *_adaptor;
	CMTime _lastTime;
}

- (BOOL)beginExportToURL:(NSURL *)url size:(NSSize)size
{
	NSError *error = nil;
	
	_videoWriter = [[AVAssetWriter alloc] initWithURL:url
											 fileType:AVFileTypeQuickTimeMovie
												error:&error];
	
	if (!_videoWriter) {
		NSLog(@"Could not create video writer. Error: %@", error);
		return NO;
	}
	
	_lastTime = CMTimeMakeWithSeconds(0, 600);
	
	NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
								   AVVideoCodecH264, AVVideoCodecKey,
								   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
								   [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
	
	_writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
													  outputSettings:videoSettings];
	
	if (![_videoWriter canAddInput:_writerInput]) {
		NSLog(@"Cannot add video writer input.");
		return NO;
	}
	
	[_videoWriter addInput:_writerInput];
	
	_adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_writerInput
																				sourcePixelBufferAttributes:nil];
	
	if (![_videoWriter startWriting]) {
		NSLog(@"Could not start writing.");
		return NO;
	}
	
	[_videoWriter startSessionAtSourceTime:kCMTimeZero];
	
	return YES;
}

- (BOOL)addImageRep:(NSBitmapImageRep *)imageRep forLength:(NSTimeInterval)seconds
{
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																	pixelsWide:[imageRep pixelsWide]
																	pixelsHigh:[imageRep pixelsHigh]
																 bitsPerSample:8
															   samplesPerPixel:4
																	  hasAlpha:YES isPlanar:NO
																colorSpaceName:NSCalibratedRGBColorSpace
																  bitmapFormat:NSAlphaFirstBitmapFormat
																   bytesPerRow:0
																  bitsPerPixel:0];
	
	[NSGraphicsContext saveGraphicsState];
	
	NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
	[NSGraphicsContext setCurrentContext:ctx];
	
	NSRect bounds = NSMakeRect(0, 0, [imageRep pixelsWide], [imageRep pixelsHigh]);
	
	[[NSColor whiteColor] set];
	NSRectFill(bounds);
	
	[imageRep drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:YES hints:nil];
	
	[NSGraphicsContext restoreGraphicsState];
	
	CVPixelBufferRef buffer = NULL;
	CVReturn result = CVPixelBufferCreateWithBytes(NULL, [rep pixelsWide], [rep pixelsHigh], kCVPixelFormatType_32ARGB, [rep bitmapData], [rep bytesPerRow], NULL, NULL, NULL, &buffer);
	
	if (result != kCVReturnSuccess) {
		NSLog(@"Could not allocate pixel buffer. Code: %d", result);
		return NO;
	}
	
	while (!_adaptor.assetWriterInput.readyForMoreMediaData);
	
	if (![_adaptor appendPixelBuffer:buffer withPresentationTime:_lastTime]) {
		NSLog(@"Could not append pixel buffer.");
		CVPixelBufferRelease(buffer);
		return NO;
	}
	
	CMTime frameTime = CMTimeMake(seconds * 600, 600);
	_lastTime = CMTimeAdd(_lastTime, frameTime);
	
	CVPixelBufferRelease(buffer);
	
	return YES;
}

- (void)finishExport
{
	[_writerInput markAsFinished];
	[_videoWriter finishWriting];
}

//- (BOOL)movie:(QTMovie *)movie
//shouldContinueOperation:(NSString *)op
//		withPhase:(QTMovieOperationPhase)phase
//		atPercent:(NSNumber *)percent
//withAttributes:(NSDictionary *)attributes
//{
//	OSProgressPopup *pop = [OSProgressPopup sharedProgressPopup];
//	switch (phase)
//	{
//		case QTMovieOperationBeginPhase:
//			[pop setCanCancel:YES];
//			[pop beginOperationWithStatusText:@"Exporting Movie..." parentWindow:nil];
//			break;
//		case QTMovieOperationUpdatePercentPhase:
//			[[OSProgressPopup sharedProgressPopup] setProgress:[percent doubleValue] * 100];
//			break;
//		case QTMovieOperationEndPhase:
//			[[OSProgressPopup sharedProgressPopup] endOperation];
//			break;
//	}
//
//	// This is such an amazing hack. But it was provided by Apple!
//	NSButton *cancelButton = [pop valueForKey:@"cancelButton"];
//	NSWindow *popup = [pop valueForKey:@"window"];
//	NSEvent *event =
//	[popup nextEventMatchingMask:NSLeftMouseUpMask
//										 untilDate:[NSDate distantPast]
//												inMode:NSDefaultRunLoopMode
//											 dequeue:YES];
//	if (event && NSPointInRect([event locationInWindow], [cancelButton frame]))
//	{
//		[cancelButton performClick:self];
//		[self movie:movie
//shouldContinueOperation:nil 
//			withPhase:QTMovieOperationEndPhase 
//			atPercent:nil 
// withAttributes:nil];
//		return NO;
//	}
//	return YES;
//}

@end
