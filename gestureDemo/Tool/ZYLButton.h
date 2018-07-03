//
//  ZYLButton.h
//  LiveTest
//
//  Created by PlayOne on 2018/5/23.
//  Copyright © 2018年 IOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ZYLButtonDelegate <NSObject>

//开始触摸
- (void)touchesBeganWithPoint:(CGPoint)point;

//移动手指
- (void)touchesMoveWithPoint:(CGPoint)point;

@end

@interface ZYLButton : UIButton
//传递点击事件的代理
@property (weak, nonatomic) id <ZYLButtonDelegate> touchDelegate;
@end
