//
//  SEDIFY_TipsView.h
//  TipsView
//
//  Created by Steve Milano on 11/18/10.
//  Copyright 2010 by SEDIFY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SEDIFY_TipsView : UIView {
	UILabel * msgLabel;
	NSDictionary * msgDict;
	int msgNum;
}

@property (assign,nonatomic) NSString * msg;

- (NSString *) msgForNum:(int)msgNumber;
- (CGPoint) pointForNum:(int)msgNumber;
- (UIBezierPath *) pathForMsgNum:(int)msgNumber;

@end
