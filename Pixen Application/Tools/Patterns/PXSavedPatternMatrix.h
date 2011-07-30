//
//  PXSavedPatternMatrix.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXPattern;

@interface PXSavedPatternMatrix : NSMatrix {
  @private
	NSMutableArray *patterns;
	NSString *patternFileName;
	NSWindow *window;
}

- initWithWidth:(float)width patternFile:(NSString *)file;

- (PXPattern *)selectedPattern;
- (void)addPattern:(PXPattern *)pattern;
- (void)setPatternFile:(NSString *)file;
- (void)removeSelectedPattern;

- (void)reloadPatterns;
- (void)setupCells;
@end
