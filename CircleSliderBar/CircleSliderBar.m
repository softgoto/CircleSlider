//
//  CircleSliderBar.m
//  CircleSlider
//
//  Created by xuhui on 15/6/12.
//  Copyright (c) 2015年 xuhui. All rights reserved.
//

#import "CircleSliderBar.h"

//#define CIRCLE_X                        (67.0f)
//#define CIRCLE_Y                        (66.0f)

//控制点用的角度
#define START_ANGLE                     (-20.0f)
#define END_ANGLE                       (200.0f)

//弧线用的角度
#define LINE_START_ANGLE                (-200.0f)
#define LINE_END_ANGLE                  (20.0f)

#define CONTROL_CIRCLE_RADIUS           (40.0f)
#define LINE_CIRCLE_RADIUS              (80.0f)

#define DEGREES_TO_RADIANS(_degrees)    ((M_PI * (_degrees))/180)
#define RADIANS_TO_DEGREES(_radians)    ((_radians)*180)/M_PI

#pragma mark - CircleSlideDelegate
@class CircleSlide;
@protocol CircleSlideDelegate <NSObject>

@optional
- (void)circleSlide:(CircleSlide *)circleSlide withProgress:(float)progress;

@end

#pragma mark - CircleSlide
@interface CircleSlide : UIImageView <CircleSlideDelegate>
{
@private
//    id              _delegate;
    CGPoint         _rotatePoint;       //圆点
    float           _radius;            //半径
    float           _startAngle;        //开始角度
    float           _endAngle;          //结束角度
    
    float           _progress;          //0~1
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) float progress;

- (id)initWithImage:(UIImage *)image
        rotatePoint:(CGPoint)rotatePoint
             radius:(float)radius
         startAngle:(float)startAngle
           endAngle:(float)endAngle;
@end

@implementation CircleSlide
@synthesize delegate = _delegate;
@synthesize progress = _progress;

- (id)initWithImage:(UIImage *)image
        rotatePoint:(CGPoint)rotatePoint
             radius:(float)radius
         startAngle:(float)startAngle
           endAngle:(float)endAngle
{
    self = [super initWithImage:image];
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        _rotatePoint = rotatePoint;
        _radius = radius;
        _startAngle = startAngle;
        _endAngle = endAngle;
        _progress = 1;
        self.center = [self positionOfProgress:_progress];
    }
    return self;
}

- (void)setProgress:(float)progress
{
    if (progress >= 0 && progress <= 1.0f) {
        _progress = progress;
        self.center = [self positionOfProgress:_progress];
    }
}

- (float)progressOfAngle:(float)angle
{
    angle = MAX(angle, _startAngle);
    angle = MIN(angle, _endAngle);
    return (angle - _startAngle)/(_endAngle - _startAngle);
}

- (float)angleOfProgress:(float)progress
{
    progress = MAX(progress, 0);
    progress = MIN(progress, 1.0f);
    
    return _progress*(_endAngle - _startAngle)+_startAngle;
}

- (BOOL)samesign:(float)x y:(float)y
{
    return (x <= 0 && y <= 0) || (x >= 0 && y >= 0);
}

- (float)progressOfPosition:(CGPoint)position
{
    float x = position.x - _rotatePoint.x;
    float y = - (position.y - _rotatePoint.y);
    
    float angle = atanf(y/x);
    if (![self samesign:x y:cosf(angle)] || ![self samesign:y y:sinf(angle)]) {
        angle += M_PI;
    }
    
    return [self progressOfAngle:angle];
}

- (CGPoint)positionOfProgress:(float)progress
{
    float angle = [self angleOfProgress:_progress];
    
    CGPoint position = {_rotatePoint.x+cosf(angle)*_radius, _rotatePoint.y-sinf(angle)*_radius};
    return position;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint ptCurr=[[touches anyObject] locationInView:self.delegate];
    float newProgress = [self progressOfPosition:ptCurr];
    
    /* 判断是否发生跳跃 */
    if ((newProgress > _progress && (newProgress - _progress) < 0.5)
        || (newProgress < _progress && (_progress - newProgress) < 0.5)) {
        _progress = [self progressOfPosition:ptCurr];
        self.center = [self positionOfProgress:_progress];
        
        if (_delegate && [_delegate respondsToSelector:@selector(circleSlide:withProgress:)]) {
            [_delegate circleSlide:self withProgress:_progress];
        }
    }
}

@end

#pragma mark - VolumeBar
@interface CircleSliderBar ()
{
    UIImageView *       _backgroundView;
    CircleSlide *       _circleSlide;
//    UIImageView *       _contentView;
    
    float               _progress;/* 1表示最小音量， 0表示最大音量 */
    
    CGFloat             _CIRCLE_X;
    CGFloat             _CIRCLE_Y;
}
@end

@implementation CircleSliderBar
@dynamic currentVolume;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CircleSliderBar.bundle/vol_bg.png"]];
        [_backgroundView setFrame:_backgroundView.bounds];
        
        frame.size.width = _backgroundView.bounds.size.width;
        frame.size.height = _backgroundView.bounds.size.height;
        [self setFrame:frame];
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_backgroundView];
        
        _CIRCLE_X = self.frame.size.width/2.0;
        _CIRCLE_Y = self.frame.size.height/2.0;
        
        //control
        _circleSlide =
        [[CircleSlide alloc] initWithImage:[UIImage imageNamed:@"CircleSliderBar.bundle/vol_ctrl.png"]
                               rotatePoint:CGPointMake(_CIRCLE_X, _CIRCLE_Y)
                                    radius:CONTROL_CIRCLE_RADIUS
                                startAngle:DEGREES_TO_RADIANS(START_ANGLE)
                                  endAngle:DEGREES_TO_RADIANS(END_ANGLE)];
        _circleSlide.delegate = self;
        [self addSubview:_circleSlide];
        
        //content
//        _contentImage = [UIImage imageNamed:@"volumeBar.bundle/vol_full.png"];
//        _contentView = [[UIImageView alloc] initWithFrame:_backgroundView.bounds];
//        [self addSubview:_contentView];
        _progress = 1;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame minimumVolume:(NSInteger)minimumVolume maximumVolume:(NSInteger)maximumVolume
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        _minimumVolume = minimumVolume;
        _maximumVolume = maximumVolume;
    }
    return self;
}

//- (void)dealloc
//{
//    [_backgroundView release];
//    _backgroundView = nil;
    
//    [_circleSlide release];
//    _circleSlide = nil;
    
//    [_contentView release];
//    _contentView = nil;
//    
//    [_contentImage release];
//    _contentImage = nil;
    
//    [super dealloc];
//}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0f);
    
    // Line one
    CGContextAddArc(context, _CIRCLE_X, _CIRCLE_Y, LINE_CIRCLE_RADIUS, DEGREES_TO_RADIANS(LINE_START_ANGLE), DEGREES_TO_RADIANS(LINE_END_ANGLE), NO);
    UIColor *aColor = [UIColor colorWithRed:235/255.0 green:237/255.0 blue:242/255.0 alpha:1];
    CGContextSetStrokeColorWithColor(context, aColor.CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextSaveGState(context);
    
    // Line two
    float endAngle = (LINE_START_ANGLE - LINE_END_ANGLE) * _progress + LINE_END_ANGLE;
    endAngle = (_progress == 0)?(endAngle+0.1):endAngle;
    CGContextAddArc(context, _CIRCLE_X, _CIRCLE_Y, LINE_CIRCLE_RADIUS, DEGREES_TO_RADIANS(LINE_START_ANGLE), DEGREES_TO_RADIANS(endAngle), NO);
    UIColor *bColor = [UIColor colorWithRed:231/255.0 green:80/255.0 blue:74/255.0 alpha:1];
    CGContextSetStrokeColorWithColor(context, bColor.CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextSaveGState(context);
    
//    CGContextRef context = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height, 8, 4 * self.bounds.size.width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);
//    
//    float endAngle = (END_ANGLE-START_ANGLE)*_progress+START_ANGLE;
//    endAngle = (_progress == 0)?(endAngle+0.1):endAngle;
//    
//    CGContextAddArc(context, CIRCLE_X, CIRCLE_Y, VOLUME_CIRCLE_RADIUS, DEGREES_TO_RADIANS(START_ANGLE), DEGREES_TO_RADIANS(endAngle), YES);
//    CGContextAddArc(context, CIRCLE_X, CIRCLE_Y, 0, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(0), YES);
//    CGContextClosePath(context);
//    CGContextClip(context);
//    CGContextDrawImage(context, self.bounds, _contentImage.CGImage);
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    UIImage *newImage = [UIImage imageWithCGImage:imageMasked];
//    CGImageRelease(imageMasked);
    
//    [_contentView setImage:newImage];
    
    [_circleSlide setProgress:_progress];
}

- (NSInteger)currentVolume
{
    return _currentVolume;
}

- (void)setCurrentVolume:(NSInteger)currentVolume
{
    if (currentVolume >= _minimumVolume && currentVolume <= _maximumVolume) {
        _progress = 1.0f - (float)(currentVolume - _minimumVolume)/(_maximumVolume - _minimumVolume);
        _currentVolume = currentVolume;
        [self setNeedsDisplay];
    }
}

#pragma mark - CircleSlideDelegate
- (void)circleSlide:(CircleSlide *)circleSlide withProgress:(float)progress
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    _progress = progress;
    [self setNeedsDisplay];
    
    NSInteger volume = (_maximumVolume - _minimumVolume)*(1-_progress);
    
    if (_currentVolume != volume) {
        _currentVolume = volume;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
