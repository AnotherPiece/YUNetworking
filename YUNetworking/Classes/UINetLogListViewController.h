//
//  UINetLogViewController.h
//  YUNetworking
//
//  Created by duan on 14-9-24.
//  Copyright (c) 2014年 duan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINetLogListViewController : UIViewController

@property(nonatomic,strong) NSArray *logNames;
@property(nonatomic,strong) NSArray *logAbstracts;
@property(nonatomic,copy) void(^logViewClose)();
@property(nonatomic) double warningTime;

@end
