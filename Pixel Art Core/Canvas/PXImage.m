//
//  PXImage.m
//  Pixen
//

#import "PXImage.h"

int PXTileBitsPerComponent = 8;
int PXTileComponentsPerPixel = 4;
int PXTileDimension = 256;

PXTile* PXTileCreate(CGPoint loc, CGSize size, unsigned char *data);
void PXTileRelease(PXTile* t);
void PXTileDraw(PXTile* t, CGRect source, CGRect dest);
PXColor PXTileColorAtXY(PXTile *t, int xv, int yv, BOOL *outSuccess);
void PXTileSetAtXY(PXTile *t, int xv, int yv, PXColor color);
unsigned int PXTileGetData(PXTile *t, unsigned char **data);
PXImage *PXImage_alloc(void);
PXTile *PXImage_tileAtXY(PXImage *self, int xv, int yv);
void PXImage_swapTiles(PXImage *self, PXImage *other);
void PXImage_drawRect(PXImage *self, NSRect rect, double opacity);

PXTile* PXTileCreate(CGPoint loc, CGSize size, unsigned char *data)
{
	static CGColorSpaceRef colorspace = NULL;
	
	if (!colorspace) {
		colorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	}
	
	PXTile *t = calloc(1, sizeof(PXTile));
	int bytesPerRow = PXTileComponentsPerPixel * size.width;
	if(data == NULL)
	{
		data = calloc(bytesPerRow*size.height, 1);
	}
	t->location = loc;
	t->painting = CGBitmapContextCreate(data, 
										size.width, 
										size.height, 
										PXTileBitsPerComponent, 
										bytesPerRow, 
										colorspace, 
										kCGImageAlphaPremultipliedLast);
	t->image = CGBitmapContextCreateImage(t->painting);
	return t;
}
void PXTileRelease(PXTile* t)
{
	void*data = CGBitmapContextGetData(t->painting);
	CGContextRelease(t->painting);
	if(data)
	{
		free(data);
	}
	CGImageRelease(t->image);
	
	free(t);
}
void PXTileDraw(PXTile* t, CGRect source, CGRect dest)
{
	CGRect fullRect = CGRectMake(t->location.x, t->location.y, CGBitmapContextGetWidth(t->painting), CGBitmapContextGetHeight(t->painting));
	if(!CGRectIntersectsRect(source, fullRect)) { return; }
	if(!t->image)
	{
		t->image = CGBitmapContextCreateImage(t->painting);
	}
    CGContextRef target = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextDrawImage(target, dest, t->image);
}

PXColor PXTileColorAtXY(PXTile *t, int xv, int yv, BOOL *outSuccess)
{
	if (xv < t->location.x || xv >= t->location.x + CGBitmapContextGetWidth(t->painting)) {
		if (outSuccess)
			*outSuccess = NO;
		
		return PXGetClearColor();
	}
	
	if (yv < t->location.y || yv >= t->location.y + CGBitmapContextGetHeight(t->painting)) {
		if (outSuccess)
			*outSuccess = NO;
		
		return PXGetClearColor();
	}
	
	unsigned x = xv - t->location.x;
	unsigned y = yv - t->location.y;
	
	unsigned char *data = CGBitmapContextGetData(t->painting);
	size_t bytesPerRow = CGBitmapContextGetBytesPerRow(t->painting);
	size_t startIndex = (CGBitmapContextGetHeight(t->painting) - 1 - y) * bytesPerRow + x * PXTileComponentsPerPixel;
	
	if (outSuccess)
		*outSuccess = YES;
	
	PXColor color;
	memcpy(&color, data + startIndex, sizeof(unsigned char) * 4);
	
	return color;
}

void PXTileSetAtXY(PXTile *t, int xv, int yv, PXColor color)
{
	if (xv < t->location.x || xv >= t->location.x + CGBitmapContextGetWidth(t->painting))
		return;
	
	if (yv < t->location.y || yv >= t->location.y + CGBitmapContextGetHeight(t->painting))
		return;
	
	unsigned x = xv - t->location.x;
	unsigned y = yv - t->location.y;
	
	if (t->image)
	{
		CGImageRelease(t->image);
		t->image = NULL;
	}
	
	unsigned char *data = CGBitmapContextGetData(t->painting);
	NSUInteger bytesPerRow = CGBitmapContextGetBytesPerRow(t->painting);
	NSUInteger startIndex = (CGBitmapContextGetHeight(t->painting) - 1 - y) * bytesPerRow + x * PXTileComponentsPerPixel;
	
	memcpy(data + startIndex, &color, 4);
}

unsigned int PXTileGetData(PXTile *t, unsigned char **data)
{
	if(data != NULL)
	{
		*data = CGBitmapContextGetData(t->painting);
	}
	return (unsigned int)(CGBitmapContextGetBytesPerRow(t->painting) * CGBitmapContextGetHeight(t->painting));
}

PXImage *PXImage_alloc()
{
	PXImage *image = (PXImage *)malloc(sizeof(PXImage));
	image->retainCount = 1;
	return image;
}

PXImage *PXImage_init(PXImage *self)
{
	self->width = 0;
	self->height = 0;
	self->tileCount = 0;
	self->tiles = calloc(1, sizeof(PXTile *));
	return self;
}

void PXImage_encodeWithCoder(PXImage *self, NSCoder *coder)
{
	id dict = [NSMutableDictionary dictionaryWithCapacity:4];
	[dict setObject:[NSNumber numberWithInt:(self->width)] forKey:@"width"];
	[dict setObject:[NSNumber numberWithInt:(self->height)] forKey:@"height"];
	NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:self->tileCount];
	int i;
	for (i = 0; i < self->tileCount; i++)
	{
		PXTile *t = self->tiles[i];
		unsigned char *bytes;
		unsigned int length = PXTileGetData(t, &bytes);
		NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
						   NSStringFromPoint((*(NSPoint *)&(t->location))), @"location",
						   [NSData dataWithBytes:bytes length:length], @"data", nil];
		[tiles addObject:d];
	}
	[dict setObject:tiles forKey:@"tiles"];
	[coder encodeObject:dict forKey:@"image"];
}

//we pass `palette` along for legacy (3.2) reasons
PXImage *PXImage_initWithCoder(PXImage *self, NSCoder *coder, PXPalette *palette)
{
	PXImage_init(self);
	NSDictionary *dict = [coder decodeObjectForKey:@"image"];
	self->width = [[dict objectForKey:@"width"] intValue];
	self->height = [[dict objectForKey:@"height"] intValue];
	self->tileCount = 0;
	self->tiles = NULL;
	if([dict objectForKey:@"colorIndices"]) {
		NSUInteger imageSize = self->width * self->height;
		
		unsigned int *colorIndices = (unsigned int *) malloc(sizeof(unsigned int) * imageSize);
		memcpy(colorIndices, [[dict objectForKey:@"colorIndices"] bytes], sizeof(unsigned int) * imageSize);
		
		for (int i = 0; i < imageSize; i++) {
			PXColor color = [palette colorAtIndex:colorIndices[i]];
			PXImage_setColorAtXY(self, color, i % self->width, (int)(i / self->width));
		}
	}
	else {
		NSArray *tileArray = [dict objectForKey:@"tiles"];
		if(tileArray.count > 0) {
			self->tiles = calloc([tileArray count], sizeof(PXTile *));
			for (id current in tileArray)
			{
				NSPoint pt = NSPointFromString([current objectForKey:@"location"]);
				int bytesPerRow = PXTileComponentsPerPixel * PXTileDimension;
				unsigned char *data = calloc(bytesPerRow*PXTileDimension, 1);
				memcpy(data, [[current objectForKey:@"data"] bytes], sizeof(unsigned char) * bytesPerRow * PXTileDimension);
				self->tiles[self->tileCount] = PXTileCreate((*(CGPoint *)&(pt)), CGSizeMake(PXTileDimension, PXTileDimension), data);
				self->tileCount++;
			}
		}
	}
	return self;
}

PXImage *PXImage_initWithSize(PXImage *self, NSSize size)
{
	PXImage_init(self);
	self->width = size.width;
	self->height = size.height;
	return self;
}

void PXImage_dealloc(PXImage *self)
{
	if(self->tiles)
	{
		unsigned i;
		for (i = 0; i < self->tileCount; i++)
		{
			if(self->tiles[i])
			{
				PXTileRelease(self->tiles[i]);
			}
		}
		free(self->tiles);
	}
	free(self);
}

PXImage *PXImage_copy(PXImage *self)
{
	PXImage *image = PXImage_init(PXImage_alloc());
	image->width = self->width;
	image->height = self->height;
	image->tileCount = self->tileCount;
	free(image->tiles);
	image->tiles = calloc(self->tileCount, sizeof(PXTile *));
	int i;
	for (i = 0; i < self->tileCount; i++)
	{
		PXTile *t = self->tiles[i];
		unsigned char *bytes;
		unsigned int length = PXTileGetData(t, &bytes);
		unsigned char *copyBytes = calloc(length, sizeof(unsigned char));
		memcpy(copyBytes, bytes, length);
		image->tiles[i] = PXTileCreate(t->location, 
									   CGSizeMake(PXTileDimension, PXTileDimension), copyBytes);
	}	
	return image;
}

PXImage *PXImage_retain(PXImage *self)
{
	if (self == nil) {
		return self;
	}
	self->retainCount++;
	return self;
}

PXImage *PXImage_release(PXImage *self)
{
	if (self == nil) {
		return self;
	}
	self->retainCount--;
	if (self->retainCount <= 0) {
		PXImage_dealloc(self);
	}
	return self;
}

PXTile *PXImage_tileAtXY(PXImage *self, int xv, int yv)
{
	CGPoint tileLocation = CGPointMake((xv / PXTileDimension) * PXTileDimension, (yv / PXTileDimension) * PXTileDimension);
	PXTile *t;
	BOOL found = NO;
	int i;
	for (i = 0; i < self->tileCount; i++)
	{
		t = self->tiles[i];
		if(CGPointEqualToPoint(t->location, tileLocation))
		{
			found = YES;
			break;
		}
	}
	if(!found)
	{
		self->tileCount++;
		self->tiles = realloc(self->tiles, self->tileCount * sizeof(PXTile*));
		self->tiles[self->tileCount-1] = PXTileCreate(tileLocation, CGSizeMake(PXTileDimension, PXTileDimension), NULL);
		t = self->tiles[self->tileCount-1];
	}
	return t;
}

PXColor PXImage_colorAtIndex(PXImage *self, unsigned index)
{
	int xLoc = index % self->width;
	int yLoc = (index - (index % self->width))/self->width;
	
	return PXImage_colorAtXY(self, xLoc, self->height - yLoc - 1);
}

PXColor PXImage_colorAtXY(PXImage *self, int x, int y)
{
	BOOL success = NO;
	PXColor color = PXTileColorAtXY(PXImage_tileAtXY(self, x, y), x, y, &success);
	
	if (!success) {
		@throw [NSException exceptionWithName:NSInternalInconsistencyException
									   reason:@"A NULL color shouldn't be returned from the image"
									 userInfo:nil];
	}
	
	return color;
}

void PXImage_setColorAtIndex(PXImage *self, PXColor color, unsigned loc)
{
	int xLoc = loc % self->width;
	int yLoc = (loc - (loc % self->width))/self->width;
	PXImage_setColorAtXY(self, color, xLoc, self->height - yLoc - 1);
}

void PXImage_setColorAtXY(PXImage *self, PXColor color, int xv, int yv)
{
	PXTile *t = PXImage_tileAtXY(self, xv, yv);
	PXTileSetAtXY(t, xv, yv, color);
}

void PXImage_replaceColorWithColor(PXImage *self, PXColor srcColor, PXColor destColor)
{
	for (int y = 0; y < self->height; y += PXTileDimension)
	{
		for (int x = 0; x < self->width; x += PXTileDimension)
		{
			PXTile *tile = PXImage_tileAtXY(self, x, y);
			
			unsigned char *data = CGBitmapContextGetData(tile->painting);
			size_t size = CGBitmapContextGetWidth(tile->painting) * CGBitmapContextGetHeight(tile->painting);
			
			for (size_t n = 0; n < size; n++) {
				const void *mem = (data + n*PXTileComponentsPerPixel);
				
				if (!memcmp(mem, &srcColor, 4)) {
					data[n*PXTileComponentsPerPixel+0] = destColor.r;
					data[n*PXTileComponentsPerPixel+1] = destColor.g;
					data[n*PXTileComponentsPerPixel+2] = destColor.b;
					data[n*PXTileComponentsPerPixel+3] = destColor.a;
				}
			}
			
			if (tile->image)
			{
				CGImageRelease(tile->image);
				tile->image = NULL;
			}
		}
	}
}

NSData *PXImage_colorData(PXImage *self)
{
	NSMutableData *colorData = [[NSMutableData alloc] init];
	
	for (int y = 0; y < self->height; y += PXTileDimension)
	{
		for (int x = 0; x < self->width; x += PXTileDimension)
		{
			PXTile *tile = PXImage_tileAtXY(self, x, y);
			
			unsigned char *data = CGBitmapContextGetData(tile->painting);
			size_t size = CGBitmapContextGetWidth(tile->painting) * CGBitmapContextGetHeight(tile->painting) * PXTileComponentsPerPixel;
			
			[colorData appendBytes:data length:size];
		}
	}
	
	return [colorData autorelease];
}

void PXImage_setColorData(PXImage *self, NSData *colorData)
{
	size_t offset = 0;
	
	for (int y = 0; y < self->height; y += PXTileDimension)
	{
		for (int x = 0; x < self->width; x += PXTileDimension)
		{
			PXTile *tile = PXImage_tileAtXY(self, x, y);
			
			unsigned char *data = CGBitmapContextGetData(tile->painting);
			size_t size = CGBitmapContextGetWidth(tile->painting) * CGBitmapContextGetHeight(tile->painting) * PXTileComponentsPerPixel;
			
			[colorData getBytes:data range:NSMakeRange(offset, size)];
			
			offset += size;
			
			if (tile->image)
			{
				CGImageRelease(tile->image);
				tile->image = NULL;
			}
		}
	}
}

void PXImage_clear(PXImage *self, PXColor color)
{
	for (unsigned int n = 0; n < self->width * self->height; n++)
	{
		PXImage_setColorAtIndex(self, color, n);
	}
}

void PXImage_flipHorizontally(PXImage *self)
{
	int x, y;
	for (y=0; y<self->height; y++) {
		for (x=0; x<self->width/2; x++) {
			PXColor leftColor = PXImage_colorAtXY(self, x, y);
			PXColor rightColor = PXImage_colorAtXY(self, self->width - x - 1, y);
			
			PXImage_setColorAtXY(self, rightColor, x, y);
			PXImage_setColorAtXY(self, leftColor, self->width - x - 1, y);
		}
	}
}

void PXImage_flipVertically(PXImage *self)
{
	int x, y;
	for (y=0; y<self->height/2; y++) {
		for (x=0; x<self->width; x++) {
			PXColor leftColor = PXImage_colorAtXY(self, x, y);
			PXColor rightColor = PXImage_colorAtXY(self, x, self->height - y - 1);
			
			PXImage_setColorAtXY(self, rightColor, x, y);
			PXImage_setColorAtXY(self, leftColor, x, self->height - y - 1);
		}
	}
}

#define WRAP(thing) {\
while(x##thing < 0) { x##thing += self->width; }\
while(y##thing < 0) { y##thing += self->height; }\
if(x##thing >= self->width) { x##thing -= self->width; }\
if(y##thing >= self->height) { y##thing -= self->height; }\
}	

void PXImage_translate(PXImage *self, int deltaX, int deltaY, BOOL wrap)
{
	if (deltaX == 0 && deltaY == 0) { return; }
	PXImage *copy = PXImage_copy(self);
	int startX=0, startY=0, endX=self->width-1, endY=self->height-1, x, y;
	int directionX=1, directionY=1;
	if (deltaX > 0) {
		startX = endX;
		endX = 0;
		directionX *= -1;
	}
	if (deltaY > 0) {
		startY = endY;
		endY = 0;
		directionY *= -1;
	}
	for (y=startY; y*directionY <= endY*directionY; y+=directionY) {
		for (x=startX; x*directionX <= endX*directionX; x+=directionX) {
			int xDst = x, yDst = y, xSrc = x-deltaX, ySrc = y-deltaY;
			if(wrap)
			{
				WRAP(Dst)
				WRAP(Src)
			}
			
			BOOL outOfBounds = (xSrc < 0 || ySrc < 0);
			PXColor color = outOfBounds ? PXGetClearColor() : PXImage_colorAtXY(copy, xSrc, ySrc);
			PXImage_setColorAtXY(self, color, xDst, yDst);
		}
	}
	PXImage_release(copy);
}

void PXImage_swapTiles(PXImage *self, PXImage *other)
{
	int swapC = self->tileCount;
	self->tileCount = other->tileCount;
	other->tileCount = swapC;
	PXTile **swapT = self->tiles;
	self->tiles = other->tiles;
	other->tiles = swapT;
}

void PXImage_setSize(PXImage *self, NSSize newSize, NSPoint origin, PXColor backgroundColor)
{
	PXImage *dup = PXImage_initWithSize(PXImage_alloc(), newSize);
	int i, j;
	int newWidth = newSize.width, newHeight = newSize.height;
	dup->width = newWidth;
	dup->height = newHeight;
	int originX = origin.x, originY = origin.y;
	for (i=0; i < newWidth; i++) {
		for (j=0; j < newHeight; j++) {
			if (i < originX || j < originY || 
				i >= self->width + originX || j >= self->height + originY) {
				PXImage_setColorAtXY(dup, backgroundColor, i, j);
			} else {
				PXImage_setColorAtXY(dup, PXImage_colorAtXY(self, i-originX, j-originY), i, j);
			}
		}
	}
	self->width = newWidth;
	self->height = newHeight;
	PXImage_swapTiles(self, dup);
	PXImage_release(dup);
}

void PXImage_rotateByDegrees(PXImage *self, int degrees)
{
	if (degrees != 90 && degrees != 180 && degrees != 270)
		return; // only support orthogonal rotation
	
	int i, j;
	PXImage *dup = PXImage_copy(self);
	
	// update our size if necessary
	int oldWidth = self->width;
	int oldHeight = self->height;
	
	if (degrees != 180)
	{
		self->height = oldWidth;
		self->width = oldHeight;
	}
	
	for (j = 0; j < oldHeight; j++)
	{
		for (i = 0; i < oldWidth; i++)
		{
			int x = 0, y = 0;
			
			if (degrees == 270)
			{
				x = j;
				y = self->height - 1 - i;
			}
			else if (degrees == 180)
			{
				x = self->width - 1 - i;
				y = self->height - 1 - j;
			}
			else if (degrees == 90)
			{
				x = self->width - 1 - j;
				y = i;
			}
			
			PXImage_setColorAtXY(dup, PXImage_colorAtXY(self, i, j), x, y);
		}
	}
	
	PXImage_swapTiles(self, dup);
	PXImage_release(dup);
}

void PXImage_compositeUnderInRect(PXImage *self, PXImage *other, NSRect aRect, BOOL blend)
{
	int i, j;
	PXColor topColor, bottomColor, usedColor;
	
    for (i = NSMinX(aRect); i < NSMaxX(aRect); i++)
    {
        for (j = NSMinY(aRect); j < NSMaxY(aRect); j++)
        {
			topColor = PXImage_colorAtXY(other, i, j);
			bottomColor = PXImage_colorAtXY(self, i, j);
			usedColor = topColor;
			
			if (blend) {
				usedColor = PXColorBlendWithColor(bottomColor, topColor);
			}
			if (usedColor.a != 0)
			{
				PXImage_setColorAtXY(self, usedColor, i, j);
			}
        }
    }
}

void PXImage_compositeUnder(PXImage *self, PXImage *other, BOOL blend)
{
	PXImage_compositeUnderInRect(self, other, NSMakeRect(0,0,self->width,self->height), blend);
}

void PXImage_drawRect(PXImage *self, NSRect rect, double opacity)
{
	PXImage_drawInRectFromRectWithOperationFraction(self, rect, rect, NSCompositeSourceOver, opacity);
}

void PXImage_drawInRectFromRectWithOperationFraction(PXImage *self, NSRect dst, NSRect src, NSCompositingOperation operation, double opacity)
{
	NSGraphicsContext *nsContext = [NSGraphicsContext currentContext];
	[nsContext setCompositingOperation:operation];
    CGContextRef target = (CGContextRef)[nsContext graphicsPort];
	CGContextSetAlpha(target, opacity);
	CGRect source = (*(CGRect *)&(src));

	float widthScale = NSWidth(dst) / NSWidth(src);
	float heightScale = NSHeight(dst) / NSHeight(src);
	NSRect fullDest = dst;
	fullDest.origin.x -= widthScale * (NSMinX(src) - floorf(NSMinX(src)));
	fullDest.origin.y -= heightScale * (NSMinY(src) - floorf(NSMinY(src)));
	fullDest.size.width += widthScale * (ceilf(NSWidth(src)) - NSWidth(src));
	fullDest.size.height += heightScale * (ceilf(NSHeight(src)) - NSHeight(src));
	NSAffineTransform *transform = [[NSAffineTransform alloc] init];
	[transform translateXBy:fullDest.origin.x yBy:fullDest.origin.y];
	[transform scaleXBy:widthScale yBy:heightScale];
	CGContextTranslateCTM(target, -fullDest.origin.x, -fullDest.origin.y);
	NSSize drawSize = [transform transformSize:NSMakeSize(PXTileDimension, PXTileDimension)];
	unsigned i;
	for (i = 0; i < self->tileCount; i++)
	{
		CGPoint tileLoc = self->tiles[i]->location;
		NSPoint drawPoint = [transform transformPoint:(*(NSPoint *)&(tileLoc))];
		PXTileDraw(self->tiles[i], source, CGRectMake(drawPoint.x, drawPoint.y, drawSize.width, drawSize.height));
	}
	CGContextTranslateCTM(target, fullDest.origin.x, fullDest.origin.y);
  [transform release];
}

NSBitmapImageRep *PXImage_imageRep(PXImage *self)
{
	if ((self->width <= 0) || (self->height <= 0))
		return nil;
	
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																		 pixelsWide:self->width
																		 pixelsHigh:self->height
																	  bitsPerSample:8
																	samplesPerPixel:4
																		   hasAlpha:YES
																		   isPlanar:NO
																	 colorSpaceName:NSCalibratedRGBColorSpace
																		bytesPerRow:self->width * 4
																	   bitsPerPixel:32];
	
	if (!imageRep)
		return nil;
	
	NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:ctx];
	
	PXImage_drawRect(self, NSMakeRect(0, 0, self->width, self->height), 1);
	
	[NSGraphicsContext restoreGraphicsState];
	
	return [imageRep autorelease];
}
