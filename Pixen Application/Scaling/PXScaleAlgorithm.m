//
//  PXScaleAlgorithm.m
//  Pixen
//

#import "PXScaleAlgorithm.h"
#import "PXCanvas.h"

@implementation PXScaleAlgorithm

+(id) algorithm
{
	return [[[self alloc] init] autorelease];
}

- (NSString *)name
{
	return [self nibName];
}

- (NSString *)nibName
{
	return nil;
}

- (NSString *)algorithmInfo
{
	return @"No information is available on this algorithm.";
}

- (BOOL)hasParameterView
{
	return NO;
}

NSString *PXScaleAlgorithmInvalidNibException = @"PXScaleAlgorithmInvalidNibException";

- (NSView *)parameterView
{
	if ([self nibName] != nil) {
		if (![NSBundle loadNibNamed:[self nibName] owner:self]) 
		{
			[[NSException exceptionWithName:PXScaleAlgorithmInvalidNibException reason:[NSString stringWithFormat:@"-[%@ nibName] gave an invalid nib name (%@)", [[self class] description], [self nibName]] userInfo:[NSDictionary dictionary]] raise];
		}
	}
	if (parameterView == nil) {
		return [[[NSView alloc] initWithFrame:NSZeroRect] autorelease];
	}
	return parameterView;
}

- (BOOL)canScaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size
{
	return NO;
}

- (void)scaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size
{
}

@end
