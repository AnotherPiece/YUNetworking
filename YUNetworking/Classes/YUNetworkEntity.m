//
//  YUNetworkEntity.m
//  YUNetworking
//
//  Created by duan on 14-9-23.
//  Copyright (c) 2014年 duan. All rights reserved.
//

#import "YUNetworkEntity.h"

@implementation YUNetworkEntity

+(YUNetworkEntity*)networkEntity:(id)requestTarget url:(NSString*)requestUrl type:(NSInteger)requestType parameters:(NSDictionary*)requestParameters name:(NSString*)requestName selector:(SEL)selector{
    YUNetworkEntity *networkEntity=[[YUNetworkEntity alloc] init];
    networkEntity.requestTarget=requestTarget;
    networkEntity.requestUrl=requestUrl;
    networkEntity.requestType=requestType;
    networkEntity.requestParameters=requestParameters;
    networkEntity.requestSel=selector;
    networkEntity.requestName=requestName;
    return networkEntity;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CFUUIDRef    uuidObj = CFUUIDCreate(nil);
        _requestID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
        _useTimeInterval=0;
        _startTimeInterval=0;
    }
    return self;
}

- (NSString *)debugDescription
{
    NSMutableString *parametersString=[NSMutableString string];
    for (NSString *key in self.requestParameters.allKeys) {
        [parametersString appendFormat:@" %@,%@",key,[self.requestParameters objectForKey:key]];
    }
    NSString *result=@"success";
    if (self.requestResult==YUNetworkingResult_Fail) {
        result=@"fail";
    }
    return [NSString stringWithFormat:@"<%@: %p> \r\nrequestID:%@ \r\nrequestName:%@ \r\nrequestType:%ld \r\nrequestUrl:%@ \r\nrequestTarget:%@ \r\nselector:(%@) \r\nrequestParameters:%@ \r\nerror%@ \r\nrequestState:%@ \r\nreturnObj:%@", [self class], self, self.requestID,self.requestName,(long)self.requestType,self.requestUrl,[self.requestTarget class],NSStringFromSelector(self.requestSel),parametersString,result,self.error,self.returnObj];
}

-(NSDictionary*)porpertyDictionary{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:self.requestID forKey:@"requestID"];
    if (self.requestName) {
        [dic setObject:self.requestName forKey:@"requestName"];
    }
    [dic setObject:[NSNumber numberWithInteger:self.requestType] forKey:@"requestType"];
    if (self.requestUrl) {
        [dic setObject:self.requestUrl forKey:@"requestUrl"];
    }
    if (self.requestTarget) {
        [dic setObject:NSStringFromClass([self.requestTarget class]) forKey:@"requestTarget"];
    }
    if (self.requestSel) {
        [dic setObject:NSStringFromSelector(self.requestSel) forKey:@"requestSel"];
    }
    NSMutableString *parametersString=[NSMutableString string];
    for (NSString *key in self.requestParameters.allKeys) {
        [parametersString appendFormat:@" %@,%@",key,[self.requestParameters objectForKey:key]];
    }
    [dic setObject:parametersString forKey:@"requestParameters"];
    NSString *result=@"success";
    if (self.requestResult==YUNetworkingResult_Fail) {
        result=@"fail";
    }
    [dic setObject:result forKey:@"requestResult"];
    if (self.error) {
        [dic setObject:[NSString stringWithFormat:@"%ld domain:%@",(long)self.error.code,self.error.domain] forKey:@"error"];
    }
    if (self.returnObj) {
        [dic setObject:self.returnObj forKey:@"returnObj"];
    }
    if (self.startTime) {
        [dic setObject:self.startTime forKey:@"startTime"];
    }
    if (self.logPath) {
        [dic setObject:self.logPath forKey:@"logPath"];
    }
    if (self.useTimeInterval>0) {
        [dic setObject:[NSNumber numberWithDouble:self.useTimeInterval] forKey:@"useTimeInterval"];
    }
    return dic;
}

- (void)dealloc
{
    
}

@end
