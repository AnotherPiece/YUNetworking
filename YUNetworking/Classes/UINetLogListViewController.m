//
//  UINetLogViewController.m
//  YUNetworking
//
//  Created by duan on 14-9-24.
//  Copyright (c) 2014年 duan. All rights reserved.
//

#import "UINetLogListViewController.h"
#import "UINetLogDetailViewController.h"

@interface UINetLogListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *contentTableView;
}
@end

@implementation UINetLogListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"日志列表";
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeLogView)];
    contentTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    contentTableView.delegate=self;
    contentTableView.dataSource=self;
    contentTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    contentTableView.separatorColor=[UIColor whiteColor];
    [self.view addSubview:contentTableView];
}

-(void)closeLogView{
    self.logViewClose();
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.logNames.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *logRowIdentifier=@"logRowIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:logRowIdentifier];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:logRowIdentifier];
        cell.textLabel.font=[UIFont systemFontOfSize:12];
        
        UILabel *errorLabel=[[UILabel alloc] initWithFrame:CGRectMake(270, 12, 50, 11)];
        errorLabel.font=[UIFont systemFontOfSize:10];
        errorLabel.backgroundColor=[UIColor clearColor];
        errorLabel.tag=1001;
        
        [cell addSubview:errorLabel];
        
        UILabel *timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(270, 22, 50, 11)];
        timeLabel.font=[UIFont systemFontOfSize:10];
        timeLabel.backgroundColor=[UIColor clearColor];
        timeLabel.tag=1002;
        
        [cell addSubview:timeLabel];
    }
    UILabel *errorLabel=(UILabel*)[cell viewWithTag:1001];
    UILabel *timeLabel=(UILabel*)[cell viewWithTag:1002];
    NSDictionary *abDic=[self.logAbstracts objectAtIndex:indexPath.row];
    if ([abDic objectForKey:@"error"]) {
        errorLabel.text=@"fail";
        errorLabel.textColor=[UIColor redColor];
    }else{
        errorLabel.text=@"success";
        errorLabel.textColor=[UIColor blackColor];
    }
    NSTimeInterval useTime=[[abDic objectForKey:@"time"] doubleValue];
    timeLabel.text=[NSString stringWithFormat:@"%.3f",useTime];
    if (useTime>=self.warningTime) {
        timeLabel.textColor=[UIColor redColor];
    }else{
        timeLabel.textColor=[UIColor blackColor];
    }
    cell.textLabel.text=[self.logNames objectAtIndex:indexPath.row];
    
    if (indexPath.row%2==0) {
        cell.backgroundColor=[UIColor whiteColor];
    }else{
        cell.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UINetLogDetailViewController *logDetailViewController=[[UINetLogDetailViewController alloc] init];
    NSDictionary *abDic=[self.logAbstracts objectAtIndex:indexPath.row];
    logDetailViewController.logPath=[abDic objectForKey:@"path"];
    [self.navigationController pushViewController:logDetailViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc
{
    
}

@end
