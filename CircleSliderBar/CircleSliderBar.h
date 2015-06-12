//
//  CircleSliderBar.h
//  CircleSlider
//
//  Created by xuhui on 15/6/12.
//  Copyright (c) 2015年 xuhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleSliderBar : UIControl
{
@private
    NSInteger _minimumVolume;
    NSInteger _maximumVolume;
    
    NSInteger _currentVolume;
}
@property (nonatomic, assign) NSInteger currentVolume;

- (id)initWithFrame:(CGRect)frame minimumVolume:(NSInteger)minimumVolume maximumVolume:(NSInteger)maximumVolume;

@end
