//
//  PXHotkeyFormatter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXHotkeyFormatter.h"

@implementation PXHotkeyFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
	if (![anObject isKindOfClass:[NSString class]])
		return nil;
	
	if ([anObject length] > 0)
	{
		unichar theCharacter = [anObject characterAtIndex:([anObject length] - 1)];
		
		if(![[NSCharacterSet letterCharacterSet] characterIsMember:theCharacter])
			return nil;
		
		return [NSString stringWithFormat:@"%c", theCharacter];
	}
	else {
		return @"";
	}
}

- (BOOL)isPartialStringValid:(NSString *)partialString
			newEditingString:(NSString **)newString
			errorDescription:(NSString **)error
{
	if ([partialString length] > 0)
	{
		unichar theCharacter = [partialString characterAtIndex:([partialString length] - 1)];
		
		if(![[NSCharacterSet letterCharacterSet] characterIsMember:theCharacter])
		{
			*newString = nil;
			return NO;
		}
		
		if ([partialString length] > 1)
		{
			*newString = [NSString stringWithFormat:@"%c", theCharacter];
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
	*anObject = [[string copy] autorelease];
	return YES;
}

//FIXME: why attributes param is for ?
//Required argument of this method for NSFormatter subclasses to implement.

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject
									 defaultAttributes:(NSDictionary *)attributes
{
	return [[[NSAttributedString alloc] initWithString:[self stringForObjectValue:anObject]] autorelease];
}

@end
