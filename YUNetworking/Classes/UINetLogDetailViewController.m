//
//  UINetLogDetailViewController.m
//  YUNetworking
//
//  Created by duan on 14-9-24.
//  Copyright (c) 2014年 duan. All rights reserved.
//

#import "UINetLogDetailViewController.h"

@interface UINetLogDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *contentTableView;
    NSDictionary *logDic;
    NSArray *allKeys;
}
@end

@implementation UINetLogDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"日志详情";
    self.view.backgroundColor=[UIColor whiteColor];
    allKeys=[NSArray arrayWithObjects:@"requestID",@"requestName",@"requestType",@"requestUrl",@"requestTarget",@"requestSel",@"requestParameters",@"requestResult",@"startTime",@"useTimeInterval",@"error",@"returnObj", nil];
    logDic=[NSDictionary dictionaryWithContentsOfFile:self.logPath];
    
    contentTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    contentTableView.delegate=self;
    contentTableView.dataSource=self;
    contentTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    contentTableView.separatorColor=[UIColor whiteColor];
    [self.view addSubview:contentTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return allKeys.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key=[allKeys objectAtIndex:indexPath.row];
    if ([key isEqualToString:@"returnObj"]) {
        return 250;
    }
    return 60;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *logRowIdentifier=@"logRowIdentifier";
    static NSString *logTextViewIdentifier=@"logTextViewIdentifier";
    NSString *key=[allKeys objectAtIndex:indexPath.row];
    NSString *currIdentifier=logRowIdentifier;
    if ([key isEqualToString:@"returnObj"]) {
        currIdentifier=logTextViewIdentifier;
    }
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:currIdentifier];
    
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:currIdentifier];
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(5,5, 310, 15)];
        titleLabel.font=[UIFont boldSystemFontOfSize:14];
        titleLabel.tag=1001;
        titleLabel.textColor=[UIColor blackColor];
        titleLabel.backgroundColor=[UIColor clearColor];
        [cell addSubview:titleLabel];
        
        if ([key isEqualToString:@"returnObj"]) {
            UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(5, 25, 310, 225)];
            textView.font=[UIFont systemFontOfSize:12];
            textView.tag=1003;
            textView.textColor=[UIColor colorWithWhite:0.1 alpha:1];
            textView.backgroundColor=[UIColor clearColor];
            textView.editable=NO;
            [cell addSubview:textView];
        }
        else{
            UILabel *detailLabel=[[UILabel alloc] initWithFrame:CGRectMake(5,20, 310, 35)];
            detailLabel.font=[UIFont systemFontOfSize:12];
            detailLabel.tag=1002;
            detailLabel.textColor=[UIColor colorWithWhite:0.1 alpha:1];
            detailLabel.numberOfLines=0;
            detailLabel.backgroundColor=[UIColor clearColor];
            [cell addSubview:detailLabel];
        }
        
    }
    UILabel *titleLabel=(UILabel*)[cell viewWithTag:1001];
    titleLabel.text=key;
    if ([key isEqualToString:@"returnObj"]){
        UITextView *textView=(UITextView*)[cell viewWithTag:1003];
        id obj=[logDic objectForKey:key];
        if (obj) {
            if ([obj isKindOfClass:[NSString class]]) {
                textView.text=obj;
            }else{
                textView.text=[NSString stringWithFormat:@"%@",obj];
            }
        }else{
            textView.text=@"";
        }
    }else{
        UILabel *detailLabel=(UILabel*)[cell viewWithTag:1002];
        id obj=[logDic objectForKey:key];
        if (obj) {
            if ([obj isKindOfClass:[NSString class]]) {
                detailLabel.text=obj;
            }else
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSNumber *objNum=obj;
                detailLabel.text=[objNum stringValue];
            }else{
                detailLabel.text=[NSString stringWithFormat:@"%@",obj];;
            }
        }
        else{
            detailLabel.text=@"";
        }
    }
    if (indexPath.row%2==0) {
        cell.backgroundColor=[UIColor whiteColor];
    }else{
        cell.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
    }
    return cell;
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
