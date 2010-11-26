//
//  SEDIFY_TipsView.m
//  TipsView
//
//  Created by Steve Milano on 11/18/10.
//  Copyright 2010 by SEDIFY. All rights reserved.
//

#import "SEDIFY_TipsView.h"


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
	NSLog(@"My dict: %@", msgDict);
	NSLog(@"I'm awake!");
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

/* */
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	[[UIColor whiteColor] set];
	[[UIColor blackColor] setStroke];
	CGRect myRect = CGRectInset(msgLabel.frame, -20, -20);
	
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(theContext, 1.0);// going to fill, don't need the stroke

	CGContextBeginPath(theContext);
	CGMutablePathRef thePath = CGPathCreateMutable();

	CGPathMoveToPoint(thePath, NULL, msgLabel.frame.origin.x, myRect.origin.y);
	CGPathAddLineToPoint(thePath, NULL, myRect.origin.x, msgLabel.frame.origin.y + msgLabel.frame.size.height);
	
	CGPathAddLineToPoint(thePath, NULL, msgLabel.frame.origin.x, msgLabel.frame.origin.y + msgLabel.frame.size.height + 20);
	CGPathAddLineToPoint(thePath, NULL, myRect.origin.x+msgLabel.frame.size.width, msgLabel.frame.origin.y + msgLabel.frame.size.height);

	CGPathAddLineToPoint(thePath, NULL, msgLabel.frame.origin.x, myRect.origin.y);

	
	// Now draw path
	CGPathCloseSubpath(thePath);
	CGContextSetShadow(theContext, CGSizeMake(5,-12.5), 12.5);

	CGContextAddPath(theContext, thePath);
	CGContextDrawPath(theContext, kCGPathFill);
	
	CGPathRelease(thePath);


	NSLog(@"%f high", msgLabel.frame.size.height);
}
/* */

/*
	Get message for msgNum value
 */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	msgNum++;
	int cnt = [[msgDict objectForKey:@"tipsList"] count];
	NSLog(@"msgNum: %d, cnt: %d", msgNum, cnt);
	if ( msgNum >= cnt )
	{
		NSLog(@"passed the test");
		[self removeFromSuperview];
		return;
	}

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
	float x = [[[[msgDict objectForKey:@"tipsList"] objectAtIndex:msgNumber] objectForKey:@"x"] floatValue];
	float y = [[[[msgDict objectForKey:@"tipsList"] objectAtIndex:msgNumber] objectForKey:@"y"] floatValue];
	return CGPointMake( x, y );
	
}

- (UIBezierPath *) pathForMsgNum:(int)msgNumber
{
	CGRect myRect = CGRectInset(msgLabel.frame, -20, -20);
	UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:myRect cornerRadius:(CGFloat)15.0];
	[path moveToPoint: CGPointMake((320 - 240)/2, (460 - 200)/2)];
	[path addLineToPoint:[self pointForNum:msgNum]];
	[path addLineToPoint:CGPointMake((320 - 200)/2, (460 - 240)/2)];
	return path;

}
- (void)dealloc {
	[msgLabel release];
    [super dealloc];
}


@end
