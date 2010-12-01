//
//  SEDIFY_TipsView.h
//  TipsView
//
//  Created by Steve Milano on 11/18/10.
//  Copyright 2010 by SEDIFY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SEDIFY_TipsViewDelegate;

@interface SEDIFY_TipsView : UIView {
	UILabel * msgLabel;
	NSDictionary * msgDict;
	NSString * hintString;
	int msgNum;
	BOOL includeShadow;

	id <SEDIFY_TipsViewDelegate> delegate;
}

@property (nonatomic, assign) id <SEDIFY_TipsViewDelegate> delegate;

@property (assign,nonatomic) NSString * msg;

- (void) initialize;
- (void) setMessage;
- (NSString *) msgForNum:(int)msgNumber;
- (CGPoint) pointForNum:(int)msgNumber;
- (CGPoint) originForNum:(int)msgNumber;
- (float) widthForNum:(int)msgNumber;
- (UIBezierPath *) pathForMsgNum:(int)msgNumber;


@end

@protocol SEDIFY_TipsViewDelegate
@optional
- (void)tipsViewDidFinish:(SEDIFY_TipsView *)view;
@end
