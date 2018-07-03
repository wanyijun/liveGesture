//
//  ViewController.m
//  LiveTest
//
//  Created by PlayOne on 2018/5/23.
//  Copyright © 2018年 IOSTeam. All rights reserved.
//

#import "ViewController.h"
#import "ZYLButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import <WebKit/WebKit.h>
#import "HcdLightView.h"
typedef NS_ENUM(NSUInteger, Direction) {
    DirectionLeftOrRight,//左右
    DirectionUpOrDown,//上下
    DirectionNone
};
@interface ViewController ()<ZYLButtonDelegate>
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (nonatomic,strong) ZYLButton *button;


@property (assign, nonatomic) Direction direction;//方向
@property (assign, nonatomic) CGPoint startPoint;//用户触摸视频时的坐标变量
@property (assign, nonatomic) CGFloat startVB;//记录用户触摸视频时的亮度和音量大小

@property (strong, nonatomic) UISlider* volumeViewSlider;//控制音量滑条
@property (strong, nonatomic) MPVolumeView *volumeView;//系统音量视图
@property (nonatomic, strong) HcdLightView *lightView;//自定义亮度视图

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.button = [[ZYLButton alloc]initWithFrame:CGRectMake(0, 0, self.playView.frame.size.width, self.playView.frame.size.height)];
    self.button.touchDelegate = self;
    [self.playView addSubview:self.button];
    self.playView.userInteractionEnabled = YES;
    
    self.volumeView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9.0 / 16.0);

    self.lightView = [HcdLightView sharedInstance];
}
- (MPVolumeView *)volumeView {
    if (_volumeView == nil)
    {
        _volumeView = [[MPVolumeView alloc] init];
        [_volumeView sizeToFit];
        for (UIView *view in [_volumeView subviews])
        {
            if ([view.class.description isEqualToString:@"MPVolumeSlider"])
            {
                self.volumeViewSlider = (UISlider *)view;
                break;
            }
        }
    }
    return _volumeView;
}

#pragma mark 代理实现方法
- (void)touchesBeganWithPoint:(CGPoint)point {
    //记录首次触摸坐标
    self.startPoint = point;
    //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
    if (self.startPoint.x <= self.button.frame.size.width / 2.0) {
        //亮度
        self.startVB = [UIScreen mainScreen].brightness;
    } else {
        //音量
        self.startVB = self.volumeViewSlider.value;
    }
    //方向置为无
     self.direction = DirectionNone;
}

- (void)touchesMoveWithPoint:(CGPoint)point {
    //得出手指在Button上移动的距离
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    //分析出用户滑动的方向 (30不是固定值)
    if (self.direction == DirectionNone) {
        if (panPoint.x >= 30 || panPoint.x <= -30) {
            //进度
            self.direction = DirectionLeftOrRight;
        } else  if (panPoint.y >= 30 || panPoint.y <= -30) {
            //音量和亮度
            self.direction = DirectionUpOrDown;
        }
    }

    if (self.direction == DirectionNone) {
        return;
    } else if (self.direction == DirectionUpOrDown) {
        //音量和亮度
        if (self.startPoint.x <= self.button.frame.size.width / 2.0) {
            //调节亮度
            self.lightView = [HcdLightView sharedInstance];
            [[UIApplication sharedApplication].keyWindow insertSubview:self.playView belowSubview:self.lightView];
            if (panPoint.y < 0)
            {
                //增加亮度
                [[UIScreen mainScreen] setBrightness:self.startVB + (-panPoint.y / 30.0 / 10)];
            } else {
                //减少亮度
                [[UIScreen mainScreen] setBrightness:self.startVB - (panPoint.y / 30.0 / 10)];
            }

        } else {
            //音量
            if (panPoint.y < 0)
            {
                //增大音量
                [self.volumeViewSlider setValue:self.startVB + (-panPoint.y / 30.0 / 10) animated:YES];
//                if (self.startVB + (-panPoint.y / 30 / 10) - self.volumeViewSlider.value >= 0.1)
//                {
//                    [self.volumeViewSlider setValue:0.1 animated:NO];
//                    [self.volumeViewSlider setValue:self.startVB + (-panPoint.y / 30.0 / 10) animated:YES];
//                }

            }
            else
            {
                //减少音量
                [self.volumeViewSlider setValue:self.startVB - (panPoint.y / 30.0 / 10) animated:YES];
            }
        }
    }

}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
