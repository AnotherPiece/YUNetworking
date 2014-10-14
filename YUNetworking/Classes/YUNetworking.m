//
//  YUHTTPRequest.m
//  YUNetworking
//
//  Created by duan on 14-9-23.
//  Copyright (c) 2014年 duan. All rights reserved.
//

#import "YUNetworking.h"
#import "UINetLogListViewController.h"

#define Key_Networking @"Key_Networking"
#define Num_MaxOperationCount 4 //线程池线程数
#define Num_AvgTime 3 //日志平均时间计算数量
#define Time_WarningRequest 0.3 //日志告警时间

#define Name_LogDictionary @"yunetslog"
#define Name_LogNamesFile @"yunetslogname"
#define Name_LogAbstractsFile @"yunetslogpath"

#define SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code)                        \
_Pragma("clang diagnostic push")                                        \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")     \
code;                                                                   \
_Pragma("clang diagnostic pop")                                         \

@interface YUNetworking(){
    NSOperationQueue *operationQueue;
    NSLock *lock;
    
    
    NSMutableArray *logNames;
    NSMutableArray *logAbstracts;
    NSMutableArray *logLastTimes;
    NSDateFormatter* dateFormatter;
    NSString *logDir;
    NSString *logNamesFile;
    NSString *logAbstractsFile;
    UIWindow *logWindow;
    UITapGestureRecognizer *logTapGestureRecognizer;
    UINavigationController *logNavController;
}
@property (nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;
@end

@implementation YUNetworking

#pragma mark 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {
        _networkLog=false;
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        operationQueue=[[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount=Num_MaxOperationCount;
        lock=[[NSLock alloc] init];
    }
    return self;
}

+(YUNetworking*)shareNetworking{
    static YUNetworking* shareNetworking;
    if (!shareNetworking) {
        shareNetworking=[[YUNetworking alloc] init];
    }
    return shareNetworking;
}

#pragma mark 请求方法

-(void)Get:(YUNetworkEntity*)networkEntity{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:networkEntity.requestUrl relativeToURL:nil] absoluteString] parameters:networkEntity.requestParameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString=[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self requestSuccess:networkEntity operation:operation responseObject:responseString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFail:networkEntity operation:operation error:error];
    }];
    operation.userInfo=[NSDictionary dictionaryWithObject:networkEntity forKey:Key_Networking];
    [lock lock];
    [operationQueue addOperation:operation];
    [operation start];
    [lock unlock];
}

-(void)Post:(YUNetworkEntity*)networkEntity{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:networkEntity.requestUrl relativeToURL:nil] absoluteString] parameters:networkEntity.requestParameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString=[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self requestSuccess:networkEntity operation:operation responseObject:responseString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFail:networkEntity operation:operation error:error];
    }];
    operation.userInfo=[NSDictionary dictionaryWithObject:networkEntity forKey:Key_Networking];
    [lock lock];
    [operationQueue addOperation:operation];
    [operation start];
    [lock unlock];
}

-(void)requestSuccess:(YUNetworkEntity*)networkEntity operation:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject{
    if (networkEntity.requestTarget&&[networkEntity.requestTarget respondsToSelector:networkEntity.requestSel]) {
        networkEntity.returnObj=responseObject;
        networkEntity.requestResult=YUNetworkingResult_Success;
        [self operationDidFinish:networkEntity];
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
                                               [networkEntity.requestTarget performSelector:networkEntity.requestSel withObject:networkEntity];
                                               );
        
    }
}

-(void)requestFail:(YUNetworkEntity*)networkEntity operation:(AFHTTPRequestOperation *)operation error:(NSError *)error{
    if (networkEntity.requestTarget&&[networkEntity.requestTarget respondsToSelector:networkEntity.requestSel]) {
        networkEntity.requestResult=YUNetworkingResult_Fail;
        networkEntity.error=error;
        [self operationDidFinish:networkEntity];
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(
                                               [networkEntity.requestTarget performSelector:networkEntity.requestSel withObject:networkEntity];
                                               );
        
    }
}

-(void)cancel:(YUNetworkEntity*)networkEntity{
    if (!operationQueue) {
        return;
    }
    [lock lock];
    for (AFHTTPRequestOperation *operation in operationQueue.operations) {
        YUNetworkEntity* operationNetworkEntity=[operation.userInfo objectForKey:Key_Networking];
        if ([operationNetworkEntity.requestID isEqualToString:networkEntity.requestID]) {
            [operation cancel];
            break;
        }
    }
    [lock unlock];
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.shouldUseCredentialStorage = NO;
    [operation setCompletionBlockWithSuccess:success failure:failure];
    return operation;
}

#pragma mark 日志管理

-(void)setNetworkLog:(BOOL)networkLog{
    _networkLog=networkLog;
    if (_networkLog) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* cacheDir = [paths objectAtIndex:0];
        logDir=[NSString stringWithFormat:@"%@/%@/",cacheDir,Name_LogDictionary];
        BOOL isDirectory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:logDir isDirectory:&isDirectory]) {
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:&error];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(operationDidStart:) name:AFNetworkingOperationDidStartNotification object:nil];
        
        if (!logWindow) {
            logWindow=[[UIWindow alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-20, 0, [UIScreen mainScreen].bounds.size.width, 20)];
            UIWindow *appWindow=[UIApplication sharedApplication].keyWindow;
            logWindow.backgroundColor=[UIColor whiteColor];
            logWindow.windowLevel=UIWindowLevelStatusBar+1;
            [logWindow makeKeyAndVisible];
            [appWindow makeKeyAndVisible];
            
            logTapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logTap)];
            logTapGestureRecognizer.numberOfTapsRequired=3;
            [logWindow addGestureRecognizer:logTapGestureRecognizer];
        }
    }
}

-(void)operationDidStart:(NSNotification*)noti{
    if (!_networkLog) {
        return;
    }
    if (!noti||!noti.object||![noti.object isKindOfClass:[AFHTTPRequestOperation class]]) {
        return;
    }
    AFHTTPRequestOperation *startOperation=noti.object;
    YUNetworkEntity* startNetworkEntity=[startOperation.userInfo objectForKey:Key_Networking];
    startNetworkEntity.startTime=[self currTimeStr];
    startNetworkEntity.startTimeInterval=[[NSDate date] timeIntervalSince1970];
}

-(void)operationDidFinish:(YUNetworkEntity*)networkEntity{
    if (!_networkLog) {
        return;
    }
    networkEntity.useTimeInterval=[[NSDate date] timeIntervalSince1970]-networkEntity.startTimeInterval;
    networkEntity.logPath=[NSString stringWithFormat:@"%@%@",logDir,networkEntity.requestID];
    if (!logNamesFile) {
        logNamesFile=[NSString stringWithFormat:@"%@%@",logDir,Name_LogNamesFile];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:logNamesFile]) {
        logNames=[NSMutableArray arrayWithContentsOfFile:logNamesFile];
    }
    if (!logNames) {
        logNames=[NSMutableArray array];
    }
    if (!logAbstractsFile) {
        logAbstractsFile=[NSString stringWithFormat:@"%@%@",logDir,Name_LogAbstractsFile];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:logAbstractsFile]) {
        logNames=[NSMutableArray arrayWithContentsOfFile:logAbstractsFile];
    }
    if (!logAbstracts) {
        logAbstracts=[NSMutableArray array];
    }
    [logNames insertObject:[NSString stringWithFormat:@"%@ %@",networkEntity.startTime,networkEntity.requestName] atIndex:0];
    NSMutableDictionary *abstractDic=[NSMutableDictionary dictionary];
    [abstractDic setObject:networkEntity.logPath forKey:@"path"];
    if (networkEntity.error||networkEntity.requestResult==YUNetworkingResult_Fail) {
        [abstractDic setObject:@"error" forKey:@"error"];
    }
    [abstractDic setObject:[NSNumber numberWithDouble:networkEntity.useTimeInterval] forKey:@"time"];
    [logAbstracts insertObject:abstractDic atIndex:0];
    if (networkEntity.requestResult==YUNetworkingResult_Success) {
        if (!logLastTimes) {
            logLastTimes=[NSMutableArray array];
        }
        [logLastTimes addObject:[NSNumber numberWithDouble:networkEntity.useTimeInterval]];
        if (logLastTimes.count>Num_AvgTime) {
            [logLastTimes removeObjectAtIndex:0];
        }
        
        NSTimeInterval timeSum=0;
        for (NSNumber *timeNum in logLastTimes) {
            timeSum=timeSum+[timeNum doubleValue];
        }
        
        self.avgTime=timeSum/logLastTimes.count;
    }
    
    NSDictionary *dic=[networkEntity porpertyDictionary];
    [dic writeToFile:networkEntity.logPath atomically:YES];
}

-(void)logTap{
    if (logWindow) {
        logWindow.windowLevel=UIWindowLevelStatusBar-1;
        [UIView animateWithDuration:0.3 animations:^{
            logWindow.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        } completion:^(BOOL finished) {
            UINetLogListViewController *logListViewController=[[UINetLogListViewController alloc] init];
            logListViewController.logNames=logNames;
            logListViewController.logAbstracts=logAbstracts;
            logListViewController.warningTime=Time_WarningRequest;
            logNavController=[[UINavigationController alloc] initWithRootViewController:logListViewController];
            [logWindow addSubview:logNavController.view];
            logListViewController.logViewClose=^(){
                [UIView animateWithDuration:0.3 animations:^{
                    logWindow.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-20,0, [UIScreen mainScreen].bounds.size.width, 20);
                } completion:^(BOOL finished) {
                    [logNavController.view removeFromSuperview];
                    logNavController=nil;
                    logWindow.windowLevel=UIWindowLevelStatusBar+1;
                }];
            };
        }];
    }
}

-(NSString*)currTimeStr{
    if (!dateFormatter) {
        dateFormatter=[[NSDateFormatter alloc] init];
        dateFormatter.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    }
    return [dateFormatter stringFromDate:[NSDate date]];
}

-(void)stop{
    if (!_networkLog) {
        return;
    }
    if (logNamesFile&&logNames){
        [logNames writeToFile:logNamesFile atomically:YES];
    }
    if (logAbstractsFile&&logAbstracts){
        [logAbstracts writeToFile:logAbstractsFile atomically:YES];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
