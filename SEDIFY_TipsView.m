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

@synthesize msg;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib
{
	msgNum = 0;
	msgDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Tips" ofType:@"plist"]];
//	NSLog(@"Tips NSDictionary should load:\n%@", msgDict);
	CGRect labelRect = CGRectMake((320 - 200)/2, (460 - 200)/2, 200, 20);
	msgLabel = [[UILabel alloc] initWithFrame:labelRect];
	[self addSubview:msgLabel];
	msgLabel.text = [self msgForNum:msgNum];
	msgLabel.lineBreakMode = UILineBreakModeWordWrap;
	msgLabel.textAlignment = UITextAlignmentLeft;
	msgLabel.numberOfLines = 0;// expands to fit
	[msgLabel sizeToFit];
	msgLabel.backgroundColor = [UIColor whiteColor];

	[self setBackgroundColor:[UIColor clearColor]];
}

- (void)dealloc {
	[msgLabel release];
	[msgDict release];
    [super dealloc];
}

/* */
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	[[UIColor whiteColor] set];
	[[UIColor blackColor] setStroke];
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	CGContextSetShadow(theContext, CGSizeMake(kShadowOffset,kShadowOffset), 2*kShadowOffset);

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
									// TODO: send message to a delegate to actually release this class
		return;
	}

	[msgLabel setFrame:CGRectMake(0, 0, [self widthForNum:msgNum], 50)];
	msgLabel.text = [self msgForNum:msgNum];
	msgLabel.numberOfLines = 0;
	[msgLabel sizeToFit];
	[self setNeedsDisplay];

}

#pragma mark -
#pragma mark Helpers
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

- (UIBezierPath *) pathForMsgNum:(int)msgNumber
{
	CGPoint myOrigin = [self originForNum:msgNum];
	[msgLabel setFrame:CGRectMake(myOrigin.x, myOrigin.y, msgLabel.frame.size.width, msgLabel.frame.size.height)];
	CGRect myRect = CGRectInset(msgLabel.frame, -kCornerRadius, -kCornerRadius);
	CGPoint myPoint = [self pointForNum:msgNum];
//	UIBezierPath * path = [UIBezierPath bezierPathWithRect:myRect];
	UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:myRect cornerRadius:(CGFloat)kCornerRadius];
	
	if ( myPoint.y < myOrigin.y ) // point is above origin of msgLabel
	{
		if ( myPoint.x <= (msgLabel.frame.origin.x + msgLabel.frame.size.width/4) )
		{ NSLog(@"first option");
			[path moveToPoint:CGPointMake(myRect.origin.x + kCornerRadius , myRect.origin.y)];
			[path addLineToPoint:myPoint];
			[path addLineToPoint:CGPointMake(msgLabel.frame.origin.x + kCornerRadius, myRect.origin.y)];
		}
		else if ( myPoint.x <= (msgLabel.frame.origin.x + 3*msgLabel.frame.size.width/4) )
		{ NSLog(@"second option");
			[path moveToPoint:CGPointMake(myRect.origin.x + myRect.size.width/2 - kCornerRadius/2, myRect.origin.y)];
			[path addLineToPoint:myPoint];
			[path addLineToPoint:CGPointMake(myRect.origin.x + myRect.size.width/2 + kCornerRadius/2, myRect.origin.y)];
		}
		else if ( myPoint.x > (msgLabel.frame.origin.x + 3*msgLabel.frame.size.width/4) )
		{ NSLog(@"third option");
			[path moveToPoint:CGPointMake(msgLabel.frame.origin.x + msgLabel.frame.size.width - kCornerRadius, myRect.origin.y)];
			[path addLineToPoint:myPoint];
			[path addLineToPoint:CGPointMake(myRect.origin.x + myRect.size.width - kCornerRadius, myRect.origin.y)];
		}
		else
		{
			NSLog(@"No option");
		}
	}
	else if (myPoint.y >= myOrigin.y && (myPoint.y <= (myOrigin.y+msgLabel.frame.size.height) ) ) // point is within vertical space of msgLabel
	{
		// assume point is either to the left or to the right of the box
		// (nothing else is meaningful; configure accordingly in Tips.plist)
		if ( myPoint.x < myRect.origin.x )
		{
			if ( myPoint.y < (msgLabel.frame.origin.y + msgLabel.frame.size.height/4 ) )
			{
				[path moveToPoint:CGPointMake(myRect.origin.x , (myRect.origin.y + kCornerRadius) )];
				[path addLineToPoint:myPoint];
				[path addLineToPoint:CGPointMake(myRect.origin.x , (myRect.origin.y + 2*kCornerRadius) )];
			}
			else if (myPoint.y < (msgLabel.frame.origin.y + 3*myRect.size.height/4) )
			{
				[path moveToPoint:CGPointMake(myRect.origin.x , (myRect.origin.y + myRect.size.height/2 - kCornerRadius/2) )];
				[path addLineToPoint:myPoint];
				[path addLineToPoint:CGPointMake(myRect.origin.x , (myRect.origin.y + myRect.size.height/2 + kCornerRadius/2) )];
			}
			else
			{
				[path moveToPoint:CGPointMake(myRect.origin.x , (myRect.origin.y + myRect.size.height - 2*kCornerRadius) )];
				[path addLineToPoint:myPoint];
				[path addLineToPoint:CGPointMake(myRect.origin.x , (myRect.origin.y + myRect.size.height/2 - kCornerRadius) )];
			}

		}
		else if (myPoint.x > (myRect.origin.x + myRect.size.width) )
		{
			if ( myPoint.y < (msgLabel.frame.origin.y + msgLabel.frame.size.height/4 ) )
			{
				[path moveToPoint:CGPointMake(myRect.origin.x + myRect.size.width , (myRect.origin.y + kCornerRadius) )];
				[path addLineToPoint:myPoint];
				[path addLineToPoint:CGPointMake(myRect.origin.x + myRect.size.width , (myRect.origin.y + 2*kCornerRadius) )];
			}
			else if (myPoint.y < (myRect.origin.y + 3*myRect.size.height/4) )
			{
				[path moveToPoint:CGPointMake(myRect.origin.x + myRect.size.width , (myRect.origin.y + myRect.size.height/2 - kCornerRadius/2) )];
				[path addLineToPoint:myPoint];
				[path addLineToPoint:CGPointMake(myRect.origin.x + myRect.size.width , (myRect.origin.y + myRect.size.height/2 + kCornerRadius/2) )];
			}
			else
			{
				[path moveToPoint:CGPointMake(myRect.origin.x + myRect.size.width , (myRect.origin.y + myRect.size.height - 2*kCornerRadius) )];
				[path addLineToPoint:myPoint];
				[path addLineToPoint:CGPointMake(myRect.origin.x + myRect.size.width , (myRect.origin.y + myRect.size.height - kCornerRadius) )];
			}
		}
	}
	else if ( myPoint.y > (myOrigin.y + myRect.size.height) ) // conditional maybe unnecessary, no other possibility
	{
		if ( myPoint.x <= (msgLabel.frame.origin.x + msgLabel.frame.size.width/4) )
		{ NSLog(@"first option");
			[path moveToPoint:CGPointMake(myRect.origin.x + kCornerRadius , myRect.origin.y + myRect.size.height )];
			[path addLineToPoint:myPoint];
			[path addLineToPoint:CGPointMake(msgLabel.frame.origin.x + kCornerRadius, myRect.origin.y + myRect.size.height)];
		}
		else if ( myPoint.x <= (msgLabel.frame.origin.x + 3*msgLabel.frame.size.width/4) )
		{ NSLog(@"second option");
			[path moveToPoint:CGPointMake(myRect.origin.x + myRect.size.width/2 - kCornerRadius/2, myRect.origin.y + myRect.size.height)];
			[path addLineToPoint:myPoint];
			[path addLineToPoint:CGPointMake(myRect.origin.x + myRect.size.width/2 + kCornerRadius/2, myRect.origin.y + myRect.size.height)];
		}
		else if ( myPoint.x > (msgLabel.frame.origin.x + 3*msgLabel.frame.size.width/4) )
		{ NSLog(@"third option");
			[path moveToPoint:CGPointMake(msgLabel.frame.origin.x + msgLabel.frame.size.width - kCornerRadius, myRect.origin.y + myRect.size.height)];
			[path addLineToPoint:myPoint];
			[path addLineToPoint:CGPointMake(myRect.origin.x + myRect.size.width - kCornerRadius, myRect.origin.y + myRect.size.height)];
		}
		else
		{
			NSLog(@"No option");
		}
	}

	[path closePath];
	return path;

}


@end
