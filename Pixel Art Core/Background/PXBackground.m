//
//  PXBackground.m
//  Pixen
//

#import "PXBackground.h"
#import "PXCanvas.h"

#import "Constants.h"
#import "PXNotifications.h"

@implementation PXBackground

@synthesize cachedImage, name;

+ (void)initialize
{
	static BOOL ready = NO;
	if (!ready)
	{
		ready = YES;
		PXMainBackgroundType = NSLocalizedString(@"Main Background", @"Main Background");
		PXAlternateBackgroundType = NSLocalizedString(@"Alternate Background", @"Alternate Background");
	}
}

- (NSImage *)previewImageOfSize:(NSSize)size
{
	NSRect imageRect = NSInsetRect(NSMakeRect(0, 0, size.width, size.height), 5, 5);
	NSImage *previewImage = [[[NSImage alloc] initWithSize:imageRect.size] autorelease];
	[previewImage lockFocus];
	[self drawRect:NSInsetRect(imageRect, -5, -5) withinRect:NSInsetRect(imageRect, -5, -5)];
	[previewImage unlockFocus];
	return previewImage;
}

- (void)dealloc
{
	[self setName:nil];
	[self setCachedImage:nil];
	[super dealloc];
}

- (id)init
{
	if ( ! ( self = [super init] ))
		return nil;
	
	[self setName:[self defaultName]];
	[self loadView];
	
	return self;
}

- (NSString *)defaultName
{
	return [self className];
}

- (void)setConfiguratorEnabled:(BOOL)enabled
{
}

- (void)changed
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PXBackgroundChangedNotificationName
														object:self];
}

- (NSImage *)cachedImageOfSize:(NSSize)size
{
	if (cachedImage == nil || !NSEqualSizes(size, cachedImageSize)) {
		cachedImageSize = size;
		
		self.cachedImage = [[[NSImage alloc] initWithSize:size] autorelease];
		[cachedImage lockFocus];
		
		NSRect rect = NSMakeRect(0, 0, size.width, size.height);
		[self drawRect:rect withinRect:rect];
		
		[cachedImage unlockFocus];
	}
	return cachedImage;
}

- (void)drawRect:(NSRect)rect
      withinRect:(NSRect)wholeRect
   withTransform:(NSAffineTransform *)aTransform
		onCanvas:(PXCanvas *)aCanvas
{
	//default behavior is to draw outside of the current transform.
	[aTransform invert];
	[aTransform concat];
	[[self cachedImageOfSize:wholeRect.size] drawInRect:rect
											   fromRect:NSOffsetRect(rect, -1*wholeRect.origin.x, -1*wholeRect.origin.y)
											  operation:NSCompositeCopy
											   fraction:1];
	[aTransform invert];
	[aTransform concat];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self doesNotRecognizeSelector:@selector(windowWillClose:)];
}

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect
{
	[self doesNotRecognizeSelector:@selector(drawRect:withinRect:)];
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] allocWithZone:zone] init];
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	[self setName:[coder decodeObjectForKey:@"name"]];
	[self loadView];
	return self;
}

@end
