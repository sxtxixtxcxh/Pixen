//
//  PXNamePrompter.h
//  Pixel Editor
//

//
// Copyright (c) 2003,2004,2005 Pixen

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

@interface PXNamePrompter : NSWindowController
{
  @private
	IBOutlet NSTextField *nameField;
	IBOutlet NSTextField *promptString;
	id _context;
	id _delegate;
	BOOL _runningModal;
	NSString *_modalString;
}

@property (nonatomic, assign) id delegate;

- (void)promptInWindow:(NSWindow *)window context:(id)contextInfo;

- (void)promptInWindow:(NSWindow *)window context:(id)contextInfo
		  promptString:(NSString *)string defaultEntry:(NSString *)entry;

+ (NSString *)promptModalWithPromptString:(NSString *)string;
- (NSString *)promptModalWithPromptString:(NSString *)string;

- (IBAction)useEnteredName:(id)sender;
- (IBAction)cancel:(id)sender;

@end

//
// Methods Implemented by the Delegate 
//
@interface NSObject(PXNamePrompterDelegate)

// The delegate receives this message when the user hits the button "Use this Name"
- (void)prompter:(id)aPrompter didFinishWithName:(NSString *)aName context:(id)context;

// The delegate receives this message when the user hits the cancel button
- (void)prompter:(id)aPrompter didCancelWithContext:(id)contextObject;

@end
