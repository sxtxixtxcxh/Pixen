//
//  PXHotkeyFormatter.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXHotkeyFormatter : NSFormatter

- (NSString *)stringForObjectValue:(id)anObject;
- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error;

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject defaultAttributes:(NSDictionary *)attributes;

@end
