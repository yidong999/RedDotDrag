//
//  ViewController.m
//  QQRedDot
//
//  Created by 王雪利 on 16/1/8.
//  Copyright © 2016年 王雪利. All rights reserved.
//

#import "ViewController.h"
#import "RedDotView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"QQScreenShot.jpg"]];
    backImgView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:backImgView];
    
    RedDotView *dot = [[RedDotView alloc]initWithPoint:CGPointMake(55, [UIScreen mainScreen].bounds.size.height - 50) superView:self.view];
    dot.viscosity  = 30;
    dot.bubbleWidth = 25;
    dot.bubbleColor = [UIColor redColor];
    [dot setUp];
    dot.bubbleLabel.text = @"9";
//    dot.bezierAngleFactor = 3;
    [self.view addSubview:dot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
