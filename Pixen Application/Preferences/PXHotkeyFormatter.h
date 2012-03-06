//
//  PXHotkeyFormatter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@protocol PXHotkeyFormatterDelegate;

@interface PXHotkeyFormatter : NSFormatter
{
  @private
	id < PXHotkeyFormatterDelegate > _delegate;
}

@property (nonatomic, assign) id < PXHotkeyFormatterDelegate > delegate;

- (NSString *)stringForObjectValue:(id)anObject;
- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error;

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject defaultAttributes:(NSDictionary *)attributes;

@end


@protocol PXHotkeyFormatterDelegate

- (BOOL)hotkeyFormatter:(PXHotkeyFormatter *)formatter isCharacterTaken:(unichar)character;

@end
