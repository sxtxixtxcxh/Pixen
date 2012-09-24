//
//  PXToolPaletteController.m
//  Pixen
//

#import "PXToolPaletteController.h"
#import "PXToolSwitcher.h"
#import "PXPanelManager.h"

#import "PXNotifications.h"

@interface PXToolPaletteController (Private)
- (void)_openRightToolSwitcher;
- (void)_closeRightToolSwitcher;
@end

//
// PXToolPaletteController implementation
//

@implementation PXToolPaletteController

@synthesize leftSwitcher, rightSwitcher, minimalView, rightSwitchView, triangle, rightToolGradient;

static NSString *const kLeftToolColorKey = @"leftToolColor";
static NSString *const kRightToolColorKey = @"rightToolColor";

- (void)_openRightToolSwitcher
{
	[minimalView setFrameOrigin:NSMakePoint(0, NSHeight([rightSwitchView frame]))];
	[rightSwitchView setFrameOrigin:NSZeroPoint];
	
	NSRect windowFrame = [[self window] frame];
	NSRect rightFrame = [rightSwitchView frame];
	[[self window] setFrame:NSMakeRect(NSMinX(windowFrame), NSMinY(windowFrame)-NSHeight(rightFrame), NSWidth(windowFrame), NSHeight(windowFrame)+NSHeight(rightFrame)) display:YES	animate:NO];
	
	[triangle setState:NSOnState];
	
	[[NSUserDefaults standardUserDefaults] setBool:YES
											forKey:PXRightToolSwitcherIsOpenKey];
}

- (void)_closeRightToolSwitcher
{
	[minimalView setFrameOrigin:NSZeroPoint];
	[rightSwitchView setFrameOrigin:NSMakePoint(0, -1 * NSHeight([rightSwitchView frame]))];
	NSRect windowFrame = [[self window] frame];
	NSRect rightFrame = [rightSwitchView frame];
	[[self window] setFrame:NSMakeRect(NSMinX(windowFrame), NSMinY(windowFrame)+NSHeight(rightFrame), NSWidth(windowFrame), NSHeight(windowFrame)-NSHeight(rightFrame)) display:YES	animate:NO];
	[triangle setState:NSOffState];
	[[NSUserDefaults standardUserDefaults] setBool:NO
											forKey:PXRightToolSwitcherIsOpenKey];
}

-(id) init
{
  if ( ! (self = [super initWithWindowNibName:@"PXToolPalette"] ) ) 
		return nil;

	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(lock:)
												 name:PXLockToolSwitcherNotificationName 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(unlock:)
												 name:PXUnlockToolSwitcherNotificationName 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(changedSwitcherColor:)
												 name:PXToolColorDidChangeNotificationName
											   object:nil];
	
	[[self window] setMovableByWindowBackground:YES];
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
	
	return self;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)changedSwitcherColor:(NSNotification *)note
{
	[self invalidateRestorableState];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeObject:self.leftSwitcher.color forKey:kLeftToolColorKey];
	[coder encodeObject:self.rightSwitcher.color forKey:kRightToolColorKey];
}

- (void)restoreStateWithCoder:(NSCoder *)coder
{
	[super restoreStateWithCoder:coder];
	
	self.leftSwitcher.color = [coder decodeObjectForKey:kLeftToolColorKey];
	self.rightSwitcher.color = [coder decodeObjectForKey:kRightToolColorKey];
}

- (void)lock:(NSNotification *)aNotification
{
	usingRightToolBeforeLock = [self usingRightTool];
    _locked = YES;
    [leftSwitcher lock];
    [rightSwitcher lock];
}

- (void)unlock:(NSNotification *)aNotification
{
    _locked = NO;
    [leftSwitcher unlock];
    [rightSwitcher unlock];
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (PXToolPaletteController *)sharedToolPaletteController
{
	static PXToolPaletteController *singleInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		singleInstance = [[self alloc] init];
	});
	
	return singleInstance;
}

- (void)leftToolDoubleClicked:notification
{
	[[PXPanelManager sharedManager] toggleLeftToolProperties:nil];
}

- (void)rightToolDoubleClicked:notification
{
	[[PXPanelManager sharedManager] toggleRightToolProperties:nil];
}

-(void) awakeFromNib
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	[[NSColorPanel sharedColorPanel] setColor:[[NSColor blackColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
	//[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
	
	[leftSwitcher useToolTagged:PXPencilToolTag];
	[rightSwitcher useToolTagged:PXEraserToolTag];
		
	[nc addObserver:self 
		   selector:@selector(leftToolDoubleClicked:)
			   name:PXToolDoubleClickedNotificationName 
			 object:leftSwitcher];
	
	[nc addObserver:self
		   selector:@selector(rightToolDoubleClicked:) 
			   name:PXToolDoubleClickedNotificationName 
			 object:rightSwitcher];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:PXRightToolSwitcherIsOpenKey]) {
		NSPoint panelOrigin = [[self window] frame].origin;
		panelOrigin.y += [rightSwitchView frame].size.height;
		[[self window] setFrameOrigin:panelOrigin];
		[self _openRightToolSwitcher];
	}
	
//FIXME: use named constant?
	[[self window] setFrameAutosaveName:@"PXToolPaletteFrame"];
	keyMask = 0x0;
	
	[NSEvent addLocalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^NSEvent *(NSEvent *e) {
		[self flagsChanged:e];
		return e;
	}];
}

- (void)enterFullScreenWithDuration:(NSTimeInterval)duration
{
	NSWindow *window = [self window];
	
	_lastFrameFS = [window frame];
	
	NSRect frame = _lastFrameFS;
	frame.origin.x = 20.0f;
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:duration];
	[[window animator] setFrame:frame display:YES];
	[NSAnimationContext endGrouping];
}

- (void)exitFullScreenWithDuration:(NSTimeInterval)duration
{
	NSWindow *window = [self window];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:duration];
	[[window animator] setFrame:_lastFrameFS display:YES];
	[NSAnimationContext endGrouping];
}

//Action method
- (IBAction)disclosureClicked:(id)sender
{
	if([sender state] == NSOnState) 
		[self _openRightToolSwitcher]; 
	else 
		[self _closeRightToolSwitcher]; 
}


//Events methods

- (void)toolChanged
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PXToolDidChangeNotificationName object:self];
}

- (BOOL)usingRightTool
{
	if (_locked) {
		return usingRightToolBeforeLock;
	}
	NSUInteger modFlags = [[[NSApplication sharedApplication] currentEvent] modifierFlags];
	BOOL controlReallyDown = ((modFlags & NSControlKeyMask) == NSControlKeyMask); // sometimes we don't actually receive the message.  what a bother...
	if (controlKeyDown != controlReallyDown) {
		controlKeyDown = controlReallyDown;
		[self toolChanged];
	}
	return rightMouseDown || controlKeyDown;
}

- (void)setRightMouseDown:(BOOL)down
{
	BOOL oldUsingRightTool = [self usingRightTool];
	rightMouseDown = down;
	if (oldUsingRightTool != [self usingRightTool]) {
		[self toolChanged];
	}
}

- (void)setControlKeyDown:(BOOL)down
{
	BOOL oldUsingRightTool = [self usingRightTool];
	controlKeyDown = down;
	if (oldUsingRightTool != [self usingRightTool]) {
		[self toolChanged];
	}	
}

- (void)rightMouseDown
{
	[self setRightMouseDown:YES];
}

- (void)rightMouseUp
{
	[self setRightMouseDown:NO];
}

- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc
{
	if([event modifierFlags] & NSControlKeyMask)
		[rightSwitcher keyDown:event fromCanvasController:cc];
	else
		[leftSwitcher keyDown:event fromCanvasController:cc];
}

- (BOOL)keyWasDown:(NSUInteger)mask
{
    return (keyMask & mask) == mask;
}

- (BOOL)isMask:(NSUInteger)newMask upEventForModifierMask:(unsigned int)mask
{
    return [self keyWasDown:mask] && ((newMask & mask) == 0x0000);
}

- (BOOL)isMask:(NSUInteger)newMask downEventForModifierMask:(unsigned int)mask
{
    return ![self keyWasDown:mask] && ((newMask & mask) == mask);
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	if([self isMask:[theEvent modifierFlags] downEventForModifierMask:NSControlKeyMask])
    {
		[self setControlKeyDown:YES];
		keyMask |= NSControlKeyMask;
    }
	else if([self isMask:[theEvent modifierFlags] upEventForModifierMask:NSControlKeyMask])
    {
		[self setControlKeyDown:NO];
		keyMask ^= NSControlKeyMask;
    }
	
	if([self isMask:[theEvent modifierFlags] downEventForModifierMask:NSAlternateKeyMask])
    {
		[leftSwitcher optionKeyDown];
		[rightSwitcher optionKeyDown];
		keyMask |= NSAlternateKeyMask;
    }
	else if([self isMask:[theEvent modifierFlags] upEventForModifierMask:NSAlternateKeyMask])
    {
		[leftSwitcher optionKeyUp];
		[rightSwitcher optionKeyUp];
		keyMask ^= NSAlternateKeyMask;
    }
    
	if([self isMask:[theEvent modifierFlags] downEventForModifierMask:NSShiftKeyMask])
    {
		[leftSwitcher shiftKeyDown];
		[rightSwitcher shiftKeyDown];
		keyMask |= NSShiftKeyMask;
    }
	else if([self isMask:[theEvent modifierFlags] upEventForModifierMask:NSShiftKeyMask])
    {
		[leftSwitcher shiftKeyUp];
		[rightSwitcher shiftKeyUp];
		keyMask ^= NSShiftKeyMask;
    }
	
	if([self isMask:[theEvent modifierFlags] downEventForModifierMask:NSCommandKeyMask])
    {
		[leftSwitcher commandKeyDown];
		[rightSwitcher commandKeyDown];
		keyMask |= NSCommandKeyMask;
    }
	else if([self isMask:[theEvent modifierFlags] upEventForModifierMask:NSCommandKeyMask])
    {
		[leftSwitcher commandKeyUp];
		[rightSwitcher commandKeyUp];
		keyMask ^= NSCommandKeyMask;
    }
}

//
//Accessors methods
//
-(PXTool *) leftTool
{
	return [leftSwitcher selectedTool];
}

-(PXTool *) rightTool
{
	return [rightSwitcher selectedTool];
}

-(PXTool *) currentTool
{
	PXToolSwitcher *currentSwitcher = [self usingRightTool] ? rightSwitcher : leftSwitcher;
	return [currentSwitcher selectedTool];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	[rightToolGradient setHidden:NO];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	[rightToolGradient setHidden:YES];
}

@end
