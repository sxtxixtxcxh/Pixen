//
//  CTGradientView.m
//
//  Created by Chad Weider on 12/2/05.
//  Copyright (c) 2005 Cotingent.
//  Some rights reserved: <http://creativecommons.org/licenses/by/2.5/>
//

#import "CTGradientView.h"

@implementation CTGradientView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) 
		{
		myGradient = [[CTGradient aquaSelectedGradient] retain];
		
		angle = 90;
		isRadial = NO;
		}
    return self;
}

- (void)dealloc
  {
  [myGradient release];
  [super dealloc];
  }

- (BOOL)isOpaque
  {
  return NO;
  }

- (void)drawRect:(NSRect)rect
  {
  CTGradient *aGradient = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:myGradient]];
  
  
  if(isRadial)
	[aGradient radialFillRect:rect];
  else
	[aGradient fillRect:rect angle:angle];
  }

- (IBAction)changeAngle:(id)sender
  {
  angle = 90.0 - [sender floatValue];
  
  [self setNeedsDisplay:YES];
  }

- (IBAction)changeType:(id)sender
  {
  if([[[sender selectedCell] title] isEqualToString:@"Axial"])
	isRadial = NO;
  else
	isRadial = YES;
    
  [self setNeedsDisplay:YES];
  }

- (IBAction)changeStyle:(id)sender
  {
  [myGradient release];
  
  switch([sender indexOfSelectedItem])
	{
	case  1: myGradient = [CTGradient aquaSelectedGradient];		break;
    case  2: myGradient = [CTGradient aquaNormalGradient  ];		break;
    case  3: myGradient = [CTGradient aquaPressedGradient ];		break;
    case  4: myGradient = [CTGradient unifiedSelectedGradient];		break;
    case  5: myGradient = [CTGradient unifiedNormalGradient  ];		break;
    case  6: myGradient = [CTGradient unifiedPressedGradient ];		break;
    case  7: myGradient = [CTGradient unifiedDarkGradient    ];		break;
	
	default: myGradient = [CTGradient gradientWithBeginningColor:[NSColor blackColor]
													 endingColor:[NSColor whiteColor]];
    }
  
  [myGradient retain];
  
  [self setNeedsDisplay:YES];
  }



@end
