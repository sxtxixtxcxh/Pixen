//
//  PXWelcomeController.m
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

#import "PXWelcomeController.h"

@implementation PXWelcomeController

@synthesize webView = _webView;

+ (id)sharedWelcomeController
{
	static PXWelcomeController *sharedWelcomeController = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedWelcomeController = [[self alloc] init];
	});
	
	return sharedWelcomeController;
}

- (id)init
{
	if ( ! ( self = [super initWithWindowNibName:@"PXDiscoverPixen"] ))
		return nil;
	
	return self;
}

- (void)dealloc
{
	self.webView = nil;
	[super dealloc];
}

- (void)awakeFromNib {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"PixenIntro" ofType:nil];
	path = [path stringByAppendingPathComponent:@"index.html"];
	NSURL *url = [NSURL fileURLWithPath:path];
	[[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
