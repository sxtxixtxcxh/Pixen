//
//  PXPercentFormatter.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXPercentFormatter.h"

@implementation PXPercentFormatter

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
	NSRegularExpression *ex1 = [NSRegularExpression regularExpressionWithPattern:@"^\\d+%$" options:0 error:nil];
	NSRegularExpression *ex2 = [NSRegularExpression regularExpressionWithPattern:@"^\\d+$" options:0 error:nil];
	
	NSUInteger match1 = [ex1 numberOfMatchesInString:partialString options:0 range:NSMakeRange(0, [partialString length])];
	NSUInteger match2 = [ex2 numberOfMatchesInString:partialString options:0 range:NSMakeRange(0, [partialString length])];
	
	return (match1 + match2) > 0;
}

@end
