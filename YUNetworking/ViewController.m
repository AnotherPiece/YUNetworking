//
//  ViewController.m
//  YUNetworking
//
//  Created by duan on 14-9-23.
//  Copyright (c) 2014年 duan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UITextView *textView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(10, 80, 100, 30);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"baidu" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btn_Events) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(10, 120, 100, 30);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"google" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btn1_Events) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(10, 160, 100, 30);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"unknow" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btn2_Events) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    [YUNetworking shareNetworking].networkLog=YES;
    textView=[[UITextView alloc] initWithFrame:CGRectMake(10, 220, 300, 200)];
    [self.view addSubview:textView];
}

-(void)btn_Events{
    [[YUNetworking shareNetworking] Post:[YUNetworkEntity networkEntity:self url:@"https://www.baidu.com" type:0 parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"value1",@"value2", nil] forKeys:[NSArray arrayWithObjects:@"key1",@"key2", nil]] name:@"baidu" selector:@selector(requestFinish:)]];
}

-(void)btn1_Events{
    [[YUNetworking shareNetworking] Post:[YUNetworkEntity networkEntity:self url:@"https://www.google.com.hk" type:0 parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"value1",@"value2", nil] forKeys:[NSArray arrayWithObjects:@"key1",@"key2", nil]] name:@"google" selector:@selector(requestFinish:)]];
}

-(void)btn2_Events{
    [[YUNetworking shareNetworking] Post:[YUNetworkEntity networkEntity:self url:@"https://www.sdd728cnsm97.com" type:0 parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"value1",@"value2", nil] forKeys:[NSArray arrayWithObjects:@"key1",@"key2", nil]] name:@"unknow" selector:@selector(requestFinish:)]];
}

-(void)requestFinish:(YUNetworkEntity*)networkEntity{
    textView.text=networkEntity.returnObj;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
