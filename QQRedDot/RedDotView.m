//
//  RedDotView.m
//  QQRedDot
//
//  Created by 王雪利 on 16/1/8.
//  Copyright © 2016年 王雪利. All rights reserved.
//

#import "RedDotView.h"

#define BezierAngle 5

@implementation RedDotView{
    
    UIBezierPath *cutePath;
    UIColor *fillColorForCute;
    UIDynamicAnimator *animator;
    UISnapBehavior  *snap;
    
    UIView *backView;
    CGFloat r1; // backView
    CGFloat r2; // frontView
    CGFloat x1;
    CGFloat y1;
    CGFloat x2;
    CGFloat y2;
    CGFloat centerDistance;
    CGFloat cosDigree;
    CGFloat sinDigree;
    
    CGFloat cosO1;
    CGFloat sinO1;
    CGFloat cosP1;
    CGFloat sinP1;
    CGFloat cosO2;
    CGFloat sinO2;
    CGFloat cosP2;
    CGFloat sinP2;
    CGFloat cosAO2T1;
    CGFloat sinAO2T1;
    CGFloat cosAO1T1;
    CGFloat sinAO1T1;
    
    CGPoint pointA; //A
    CGPoint pointB; //B
    CGPoint pointD; //D
    CGPoint pointC; //C
    CGPoint pointO; //O
    CGPoint pointP; //P
    
    CGPoint pointO1; //O1
    CGPoint pointO2; //O2
    CGPoint pointP1; //P1
    CGPoint pointP2; //P2
    
    CGFloat AT1;
    CGFloat AO2;
    CGFloat AO1;
    CGFloat O1T1;
    CGFloat O2T1;
    CGFloat P1T2;
    CGFloat P2T2;

    CGFloat BP1;
    CGFloat BP2;
    
    CGRect oldBackViewFrame;
    CGPoint initialPoint;
    CGPoint oldBackViewCenter;
    CAShapeLayer *shapeLayer;
    BOOL _isTapAnimate;
}

-(id)initWithPoint:(CGPoint)point superView:(UIView *)view{
    self = [super initWithFrame:CGRectMake(point.x, point.y, self.bubbleWidth, self.bubbleWidth)];
    if(self){
        
        initialPoint = point;
        self.containerView = view;
        
        [self.containerView addSubview:self];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}


-(void)displayLinkAction:(CADisplayLink *)dis{
    
    x1 = backView.center.x;
    y1 = backView.center.y;
    x2 = self.frontView.center.x;
    y2 = self.frontView.center.y;
    
    centerDistance = sqrtf((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
    if (centerDistance == 0) {
        cosDigree = 1;
        sinDigree = 0;
    }else{
        //角α
        cosAO1T1 = cos(BezierAngle * M_PI/180);
        sinAO1T1 = sin(BezierAngle * M_PI/180);
        
        cosDigree = (y1-y2)/centerDistance;
        sinDigree = (x2-x1)/centerDistance;
        
        //两个控制点的位置
        O1T1 = centerDistance/4;
        O2T1 = centerDistance *2/3;
        P1T2 = O1T1;
        P2T2 = O2T1;
        
        AT1 = O1T1*tan(BezierAngle * M_PI/180);
        AO1 = O1T1/cosAO1T1;
        AO2 = sqrt(pow(O2T1, 2) + pow(AT1, 2));
        
        BP1 = AO1;
        BP2 = AO2;
        
        //角β
        cosAO2T1 = O2T1/AO2;
        sinAO2T1 = AT1/AO2;
        
        cosO1 = cosDigree * cosAO1T1 - sinDigree * sinAO1T1;
        sinO1 = sinDigree * cosAO1T1 + cosDigree * sinAO1T1;
        cosO2 = cosAO2T1 * cosDigree - sinAO2T1 * sinDigree;
        sinO2 = sinDigree * cosAO2T1 + cosDigree * sinAO2T1;

        cosP1 = cosDigree * cosAO1T1 + sinDigree * sinAO1T1;
        sinP1 = sinDigree * cosAO1T1 - cosDigree * sinAO1T1;
        cosP2 = cosDigree * cosAO2T1 + sinDigree * sinAO2T1;
        sinP2 = sinDigree * cosAO2T1 - cosDigree * sinAO2T1;
    }

    r1 = oldBackViewFrame.size.width / 2 - centerDistance/self.viscosity;
    
    pointA = CGPointMake(x1-r1*cosDigree, y1-r1*sinDigree); // A
    pointB = CGPointMake(x1+r1*cosDigree, y1+r1*sinDigree); // B
    pointD = CGPointMake(x2-r2*cosDigree, y2-r2*sinDigree); // D
    pointC = CGPointMake(x2+r2*cosDigree, y2+r2*sinDigree); // C
    
    //二阶贝塞尔曲线控制点
    pointO = CGPointMake(pointA.x + (centerDistance / 2)*sinDigree, pointA.y + (centerDistance / 2)*cosDigree);
    pointP = CGPointMake(pointB.x + (centerDistance / 2)*sinDigree, pointB.y + (centerDistance / 2)*cosDigree);
    
    //三阶贝塞尔曲线控制点
    pointO1 = CGPointMake(pointA.x + centerDistance*sinO1/(4*cosAO1T1), pointA.y-centerDistance*cosO1/(4*cosAO1T1));
    pointO2 = CGPointMake(pointA.x + AO2 * sinO2, pointA.y - AO2*cosO2);
    pointP1 = CGPointMake(pointB.x + sinP1*BP1, pointB.y - cosP1 * BP1);
    pointP2 = CGPointMake(pointB.x + sinP2 * BP2, pointB.y - cosP2 * BP2);
    
    NSLog(@"sinP2:%f  sinO2:%f",sinP2,sinO2);
//    NSLog(@"pointO2: x:%f y:%f",pointO2.x,pointO2.y);
//    NSLog(@"pointP1: x:%f y:%f",pointP1.x,pointP1.y);

    
    [self drawRect];
}

-(void)drawRect{
    
    backView.center = oldBackViewCenter;
    backView.bounds = CGRectMake(0, 0, r1*2, r1*2);
    backView.layer.cornerRadius = r1;
    
    
    cutePath = [UIBezierPath bezierPath];
//    //二次贝塞尔曲线
//    [cutePath moveToPoint:pointA];
//    [cutePath addQuadCurveToPoint:pointD controlPoint:pointO];
//    [cutePath addLineToPoint:pointC];
//    [cutePath addQuadCurveToPoint:pointB controlPoint:pointP];
//    [cutePath moveToPoint:pointA];
    
    //三次贝塞尔曲线
    [cutePath moveToPoint:pointA];
    [cutePath addCurveToPoint:pointD controlPoint1:pointO1 controlPoint2:pointO2];
    [cutePath addLineToPoint:pointC];
    [cutePath addCurveToPoint:pointB controlPoint1:pointP2 controlPoint2:pointP1];
    [cutePath moveToPoint:pointA];

    //test
//    [cutePath moveToPoint:pointP1];
//    [cutePath addArcWithCenter:pointP1 radius:3 startAngle:0 endAngle:M_PI*2 clockwise:YES];
//    [cutePath addLineToPoint:pointP2];
//    [cutePath moveToPoint:pointO1];
//    [cutePath addArcWithCenter:pointO1 radius:3 startAngle:0 endAngle:M_PI*2 clockwise:YES];
//    [cutePath addLineToPoint:pointO2];
//    [cutePath moveToPoint:pointA];
    
    if (backView.hidden == NO) {
        
        shapeLayer.path = [cutePath CGPath];
        shapeLayer.fillColor = [fillColorForCute CGColor];
                [self.containerView.layer insertSublayer:shapeLayer below:self.frontView.layer];
    }
    
}


-(void)setUp{
    shapeLayer = [CAShapeLayer layer];
    _isTapAnimate = NO;
    
    self.backgroundColor = [UIColor clearColor];
    self.frontView = [[UIView alloc]initWithFrame:CGRectMake(initialPoint.x,initialPoint.y, self.bubbleWidth, self.bubbleWidth)];
    
    r2 = self.frontView.bounds.size.width / 2;
    self.frontView.layer.cornerRadius = r2;
    self.frontView.backgroundColor = self.bubbleColor;
    
    backView = [[UIView alloc]initWithFrame:self.frontView.frame];
    r1 = backView.bounds.size.width / 2;
    backView.layer.cornerRadius = r1;
    backView.backgroundColor = self.bubbleColor;
    
    self.bubbleLabel = [[UILabel alloc]init];
    self.bubbleLabel.frame = CGRectMake(0, 0, self.frontView.bounds.size.width-5, self.frontView.bounds.size.height-5);
    self.bubbleLabel.center = CGPointMake(self.frontView.bounds.size.width/2, self.frontView.bounds.size.height/2);
    self.bubbleLabel.textColor = [UIColor whiteColor];
    self.bubbleLabel.textAlignment = NSTextAlignmentCenter;
    self.bubbleLabel.font = [UIFont systemFontOfSize:13];
    [self.frontView insertSubview:self.bubbleLabel atIndex:0];
    
    [self.containerView addSubview:backView];
    [self.containerView addSubview:self.frontView];
    
    
    x1 = backView.center.x;
    y1 = backView.center.y;
    x2 = self.frontView.center.x;
    y2 = self.frontView.center.y;
    
    
    pointA = CGPointMake(x1-r1,y1);   // A
    pointB = CGPointMake(x1+r1, y1);  // B
    pointD = CGPointMake(x2-r2, y2);  // D
    pointC = CGPointMake(x2+r2, y2);  // C
    pointO = CGPointMake(x1-r1,y1);   // O
    pointP = CGPointMake(x2+r2, y2);  // P
    
    oldBackViewFrame = backView.frame;
    oldBackViewCenter = backView.center;
    
    backView.hidden = YES;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragMe:)];
    [self.frontView addGestureRecognizer:pan];
}

-(void)dragMe:(UIPanGestureRecognizer *)ges{
    CGPoint dragPoint = [ges locationInView:self.containerView];
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        backView.hidden = NO;
        fillColorForCute = self.bubbleColor;
        [self RemoveAniamtionLikeGameCenterBubble];
    }else if (ges.state == UIGestureRecognizerStateChanged){
        self.frontView.center = dragPoint;
        if (r1 <= 6) {
            fillColorForCute = [UIColor clearColor];
            backView.hidden = YES;
            [shapeLayer removeFromSuperlayer];
        }
        
    }else if (ges.state == UIGestureRecognizerStateEnded || ges.state ==UIGestureRecognizerStateCancelled || ges.state == UIGestureRecognizerStateFailed){
        
        backView.hidden = YES;
        fillColorForCute = [UIColor clearColor];
        [shapeLayer removeFromSuperlayer];
        [UIView animateWithDuration:0.5 delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frontView.center = oldBackViewCenter;
        } completion:nil];
    }
    
    [self displayLinkAction:nil];
}

-(void)RemoveAniamtionLikeGameCenterBubble{
    [self.frontView.layer removeAllAnimations];
}


@end