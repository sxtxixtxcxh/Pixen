//
//  PXHotkeyFormatter.h
//  Pixen
//

#import <Foundation/NSFormatter.h>


@interface PXHotkeyFormatter : NSFormatter
{

}

- (NSString *)stringForObjectValue:(id)anObject;

- (BOOL)getObjectValue:(id *)anObject
	     forString:(NSString*) string
      errorDescription:(NSString **)error;

-(NSAttributedString*) attributedStringForObjectValue:(id)anObject
				    defaultAttributes:attributes;

@end
