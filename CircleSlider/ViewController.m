//
//  ViewController.m
//  CircleSlider
//
//  Created by xuhui on 15/6/12.
//  Copyright (c) 2015年 xuhui. All rights reserved.
//

#import "ViewController.h"
#import "CircleSliderBar.h"

@interface ViewController ()
{
    UILabel *_label;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    CGRect frame = CGRectMake(100, 100, 0, 0);/* 大小由背景图决定 */
    CircleSliderBar *bar = [[CircleSliderBar alloc] initWithFrame:frame minimumVolume:0 maximumVolume:10];
    [bar addTarget:self action:@selector(onVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:bar];
    bar.currentVolume = 0;
    
    
    //label
    frame = bar.frame;
    frame.origin.y += frame.size.height+10;
    frame.size.height = 30;
    
    _label = [[UILabel alloc] initWithFrame:frame];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [_label setBackgroundColor:[UIColor clearColor]];
    [_label setTextColor:[UIColor blackColor]];
    
    [_label setText:[NSString stringWithFormat:@"Volume: %ld", (long)bar.currentVolume]];
    [self.view addSubview:_label];

}

#pragma mark - Event
- (void)onVolumeBarChange:(id)sender
{
    CircleSliderBar *bar = sender;
    [_label setText:[NSString stringWithFormat:@"Volume: %ld", (long)bar.currentVolume]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
