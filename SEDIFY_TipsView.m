//
//  SEDIFY_TipsView.m
//  TipsView
//
//  Created by Steve Milano on 11/18/10.
//  Copyright 2010 by SEDIFY. All rights reserved.
//

#import "SEDIFY_TipsView.h"

#define kCornerRadius 15
#define kShadowOffset 15

@implementation SEDIFY_TipsView

@synthesize delegate;
@synthesize msg;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib
{
	[self setBackgroundColor:[UIColor clearColor]]; // this transparency allows the view underneath to show through wherever we don't explicitly draw something
	[self setBackgroundColor:[UIColor colorWithRed:1 green:0.4 blue:0.2 alpha:0.7]]; // this transparency allows the view underneath to show through wherever we don't explicitly draw something
	msgNum = 0;
	includeShadow = YES; // set to NO to disable shadow (or set kShadowOffset to 0)
	msgDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Tips" ofType:@"plist"]];

	CGRect labelRect = CGRectMake(0, 0, 50, 20); // this will all be modified by setMessage
	msgLabel = [[UILabel alloc] initWithFrame:labelRect];
	[self addSubview:msgLabel];

	// set first message
	[self setMessage];
}

- (void)dealloc {
	[msgLabel release];
	[msgDict release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	[[UIColor whiteColor] set];
	[[UIColor blackColor] setStroke]; // stroke never used, see description for pathForMsgNum:

	if ( includeShadow )
	{
		CGContextRef theContext = UIGraphicsGetCurrentContext();
		CGContextSetShadow(theContext, CGSizeMake(kShadowOffset,kShadowOffset), 2*kShadowOffset);
	}

	UIBezierPath * path = [self pathForMsgNum:msgNum];
	[path fill];
}
/* */

/*
	Get message for msgNum value
 */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	msgNum++;
	int cnt = [[msgDict objectForKey:@"tipsList"] count];
	if ( msgNum >= cnt )
	{
		[self removeFromSuperview]; // NOTE: not released! View still uses memory!
		[self.delegate tipsViewDidFinish:self]; // send message to a delegate to actually release this view
		return;
	}

	[self setMessage];

	[self setNeedsDisplay];

}

#pragma mark -
#pragma mark plist file parsing
- (NSString *) msgForNum:(int)msgNumber
{
	return [[[msgDict objectForKey:@"tipsList"] objectAtIndex:msgNumber] objectForKey:@"msg"];
}

- (CGPoint) pointForNum:(int)msgNumber
{
	float x = [[[[msgDict objectForKey:@"tipsList"] objectAtIndex:msgNumber] objectForKey:@"xPoint"] floatValue];
	float y = [[[[msgDict objectForKey:@"tipsList"] objectAtIndex:msgNumber] objectForKey:@"yPoint"] floatValue];
	return CGPointMake( x, y );
	
}
- (CGPoint) originForNum:(int)msgNumber
{
	float x = [[[[msgDict objectForKey:@"tipsList"] objectAtIndex:msgNumber] objectForKey:@"xBubble"] floatValue];
	float y = [[[[msgDict objectForKey:@"tipsList"] objectAtIndex:msgNumber] objectForKey:@"yBubble"] floatValue];
	return CGPointMake( x, y );
	
}
- (float) widthForNum:(int)msgNumber
{
	return [[[[msgDict objectForKey:@"tipsList"] objectAtIndex:msgNumber] objectForKey:@"bubbleWidth"] floatValue];
}

#pragma mark -
#pragma mark bubble methods
- (void) setMessage
{
	[msgLabel setFrame:CGRectMake(0, 0, [self widthForNum:msgNum], 50)];
	// only width setting matters here, other details are reset by other methods
	
	msgLabel.text = [self msgForNum:msgNum];
	msgLabel.lineBreakMode = UILineBreakModeWordWrap;
	msgLabel.textAlignment = UITextAlignmentLeft;
	msgLabel.numberOfLines = 0; // forces UILabel to necessary number of lines
	[msgLabel sizeToFit]; // adjusts height; width is set by setFrame: above
}
- (UIBezierPath *) pathForMsgNum:(int)msgNumber
{
/*	msgNumber is the nth dictionary item in the file Tips.plist
 
	The plan here is to get the current size of the text's UILabel (msgLabel)
	and draw a rounded-rect around it, padded by constant kCornerRadius,
	which is defined at the top of this file. Then add a line from the rounded-rect
	to the target POI (Point of Interest) and another line from the POI back to
	the rounded-rect.
 
	NOTE: this path is designed for filling, not stroking, as a stroke will also trace
	the space between the lines to/from the POI.
 */
	CGPoint	thisOrigin = [self originForNum:msgNum];
	CGSize	msgLabelSize = msgLabel.frame.size;
	[msgLabel setFrame:CGRectMake(thisOrigin.x, thisOrigin.y, msgLabelSize.width, msgLabelSize.height)];

	CGPoint	msgLabelOrigin = msgLabel.frame.origin;

	CGRect	roundedRect = CGRectInset(msgLabel.frame, -kCornerRadius, -kCornerRadius);
	CGPoint poiPoint = [self pointForNum:msgNum]; // POI == Point of Interest, i.e., where tip bubble points
	
	UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:(CGFloat)kCornerRadius];
	
	if ( poiPoint.y < thisOrigin.y ) // point is above origin of msgLabel
	{
		if ( poiPoint.x <= (msgLabelOrigin.x + msgLabelSize.width/4) ) // above, left of 1/4 way across msgLabel
		{
			[path moveToPoint:CGPointMake(roundedRect.origin.x + kCornerRadius , roundedRect.origin.y)];
			[path addLineToPoint:poiPoint];
			[path addLineToPoint:CGPointMake(msgLabelOrigin.x + kCornerRadius, roundedRect.origin.y)];
		}
		else if ( poiPoint.x <= (msgLabelOrigin.x + 3*msgLabelSize.width/4) )
		{
			[path moveToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width/2 - kCornerRadius/2, roundedRect.origin.y)];
			[path addLineToPoint:poiPoint];
			[path addLineToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width/2 + kCornerRadius/2, roundedRect.origin.y)];
		}
		else if ( poiPoint.x > (msgLabelOrigin.x + 3*msgLabelSize.width/4) )
		{
			[path moveToPoint:CGPointMake(msgLabelOrigin.x + msgLabelSize.width - kCornerRadius, roundedRect.origin.y)];
			[path addLineToPoint:poiPoint];
			[path addLineToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width - kCornerRadius, roundedRect.origin.y)];
		}
		else
		{
			NSAssert(NO, @"This block should be logically unreachable.");
		}
	}
	else if (poiPoint.y >= thisOrigin.y && (poiPoint.y <= (thisOrigin.y+msgLabelSize.height) ) ) // point is within vertical space of msgLabel
	{
		// assume point is either to the left or to the right of the box
		// (nothing else is meaningful; configure accordingly in Tips.plist)
		if ( poiPoint.x < roundedRect.origin.x )
		{
			if ( poiPoint.y < (msgLabelOrigin.y + msgLabelSize.height/4 ) )
			{
				[path moveToPoint:CGPointMake(roundedRect.origin.x , (roundedRect.origin.y + kCornerRadius) )];
				[path addLineToPoint:poiPoint];
				[path addLineToPoint:CGPointMake(roundedRect.origin.x , (roundedRect.origin.y + 2*kCornerRadius) )];
			}
			else if (poiPoint.y < (msgLabelOrigin.y + 3*roundedRect.size.height/4) )
			{
				[path moveToPoint:CGPointMake(roundedRect.origin.x , (roundedRect.origin.y + roundedRect.size.height/2 - kCornerRadius/2) )];
				[path addLineToPoint:poiPoint];
				[path addLineToPoint:CGPointMake(roundedRect.origin.x , (roundedRect.origin.y + roundedRect.size.height/2 + kCornerRadius/2) )];
			}
			else
			{
				[path moveToPoint:CGPointMake(roundedRect.origin.x , (roundedRect.origin.y + roundedRect.size.height - 2*kCornerRadius) )];
				[path addLineToPoint:poiPoint];
				[path addLineToPoint:CGPointMake(roundedRect.origin.x , (roundedRect.origin.y + roundedRect.size.height/2 - kCornerRadius) )];
			}
		}
		else if (poiPoint.x > (roundedRect.origin.x + roundedRect.size.width) )
		{
			if ( poiPoint.y < (msgLabelOrigin.y + msgLabelSize.height/4 ) )
			{
				[path moveToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width , (roundedRect.origin.y + kCornerRadius) )];
				[path addLineToPoint:poiPoint];
				[path addLineToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width , (roundedRect.origin.y + 2*kCornerRadius) )];
			}
			else if (poiPoint.y < (roundedRect.origin.y + 3*roundedRect.size.height/4) )
			{
				[path moveToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width , (roundedRect.origin.y + roundedRect.size.height/2 - kCornerRadius/2) )];
				[path addLineToPoint:poiPoint];
				[path addLineToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width , (roundedRect.origin.y + roundedRect.size.height/2 + kCornerRadius/2) )];
			}
			else
			{
				[path moveToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width , (roundedRect.origin.y + roundedRect.size.height - 2*kCornerRadius) )];
				[path addLineToPoint:poiPoint];
				[path addLineToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width , (roundedRect.origin.y + roundedRect.size.height - kCornerRadius) )];
			}
		}
	}
	else if ( poiPoint.y > (thisOrigin.y + roundedRect.size.height) ) // conditional maybe unnecessary, no other possibility
	{
		if ( poiPoint.x <= (msgLabelOrigin.x + msgLabelSize.width/4) )
		{
			[path moveToPoint:CGPointMake(roundedRect.origin.x + kCornerRadius , roundedRect.origin.y + roundedRect.size.height )];
			[path addLineToPoint:poiPoint];
			[path addLineToPoint:CGPointMake(msgLabelOrigin.x + kCornerRadius, roundedRect.origin.y + roundedRect.size.height)];
		}
		else if ( poiPoint.x <= (msgLabelOrigin.x + 3*msgLabelSize.width/4) )
		{
			[path moveToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width/2 - kCornerRadius/2, roundedRect.origin.y + roundedRect.size.height)];
			[path addLineToPoint:poiPoint];
			[path addLineToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width/2 + kCornerRadius/2, roundedRect.origin.y + roundedRect.size.height)];
		}
		else if ( poiPoint.x > (msgLabelOrigin.x + 3*msgLabelSize.width/4) )
		{
			[path moveToPoint:CGPointMake(msgLabelOrigin.x + msgLabelSize.width - kCornerRadius, roundedRect.origin.y + roundedRect.size.height)];
			[path addLineToPoint:poiPoint];
			[path addLineToPoint:CGPointMake(roundedRect.origin.x + roundedRect.size.width - kCornerRadius, roundedRect.origin.y + roundedRect.size.height)];
		}
		else
		{
			NSAssert(NO, @"This block should be logically unreachable.");
		}
	}

	[path closePath];
	return path;

}

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format
{
	NSLog(@"Exception: %@",format);
}
@end
