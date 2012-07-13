//
//  PXImageBackground.m
//  Pixen
//

#import "PXImageBackground.h"
#import "PXCanvas.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Drawing.h"
#import "PathUtilities.h"

@implementation PXImageBackground

- (NSImage *)previewImageOfSize:(NSSize)size
{
	NSImage *result = [[[NSImage alloc] initWithSize:size] autorelease];
	[result lockFocus];
	[self.color set];
	NSRectFill(NSMakeRect(0, 0, size.width, size.height));
	[image drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1];
	[result unlockFocus];
	return result;
}

- (void)dealloc
{
	[image release];
	image = nil;
	[super dealloc];
}

-(NSString *) defaultName
{
    return NSLocalizedString(@"IMAGE_BACKGROUND", @"Image Background");
}

- (NSString *) nibName
{
    return @"PXImageBackgroundConfigurator";
}

- (void)setConfiguratorEnabled:(BOOL)enabled
{
    [browseButton setEnabled:enabled];
    [super setConfiguratorEnabled:enabled];
}

- (id) init
{
	if ( ! ( self = [super init] ) ) 
		return nil;
    image = [[NSImage imageNamed:@"Pixen128"] retain];
    [self setColor:[NSColor whiteColor]];
    return self;
}

- (IBAction)configuratorBrowseForImageButtonClicked:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	// fixed!  I'm reading the document types directly from the Info.plist, though...
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSArray *documentTypes = [infoDictionary objectForKey:CFBundleDocumentTypesKey];
	NSMutableArray *fileExtensions = [NSMutableArray array];
	
	for (NSDictionary *current in documentTypes)
	{
		[fileExtensions addObjectsFromArray:[current objectForKey:CFBundleTypeExtensionsKey]];
	}
	
	[panel setDirectoryURL:[NSURL fileURLWithPath:GetBackgroundImagesDirectory()]];
	[panel setAllowedFileTypes:fileExtensions];
	
	if ([panel runModal] == NSFileHandlingPanelOKButton)
	{
		NSImage *img = [[NSImage alloc] initWithContentsOfURL:[panel URL]];
		
		[self setImage:img];
		[img release];
		
		[imageNameField setStringValue:[[[panel URL] path] lastPathComponent]];
	}
}

- (void)setColor:(NSColor *)aColor
{
	[super setColor:aColor];
	[image setBackgroundColor:self.color];
}

- (void)setImage:(NSImage *)anImage
{
	[anImage retain];
	[image release];
	image = anImage;
	[image setBackgroundColor:self.color];
	if(![[self name] isEqualToString:[self defaultName]]) 
    { 
		[imageNameField setStringValue:[self name]]; 
    }
	[self changed];
}

- (void)drawRect:(NSRect)rect 
      withinRect:(NSRect)wholeRect 
   withTransform:(NSAffineTransform *) aTransform 
				onCanvas:(PXCanvas *)aCanvas
{
	[aTransform invert];
	
	NSPoint origin = [aTransform transformPoint:rect.origin];
	NSSize size = [aTransform transformSize:rect.size];

	NSAffineTransform *newTransform = [NSAffineTransform transform];
	NSAffineTransformStruct s = [aTransform transformStruct];
	CGFloat dx = s.tX, dy = s.tY;
	while(dx < 0) { dx += [aCanvas size].width; }
	while(dy < 0) { dy += [aCanvas size].height; }
	[(NSAffineTransform *)newTransform translateXBy:dx yBy:dy];
	[newTransform invert];
	origin = [newTransform transformPoint:origin];
	origin.x = floorf(origin.x);
	origin.y = floorf(origin.y);
	size.width = ceilf(size.width);
	size.height = ceilf(size.height);
	
	[newTransform invert];
	[newTransform concat];
	[self.color set];
	NSRectFill(NSMakeRect(origin.x, origin.y, size.width, size.height));
	
	[image drawInRect:NSMakeRect(0, 0, [aCanvas size].width, [aCanvas size].height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1];
	
	[newTransform invert];
	[newTransform concat];
	
	[aTransform invert];
}

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect
{
	[self.color set];
	NSRectFill(rect);
	[image drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1];
}

-(id) copyWithZone:(NSZone *)zone
{
    PXImageBackground *copy = [super copyWithZone:zone];
    [copy setImage:image];
    return copy;
}

- (void)encodeWithCoder:(NSCoder *) coder
{
	[coder encodeObject:image forKey:@"image"];
	[super encodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder*)coder
{
	self = [super initWithCoder:coder];
	[self setImage:[coder decodeObjectForKey:@"image"]];
	return self;
}

@end
