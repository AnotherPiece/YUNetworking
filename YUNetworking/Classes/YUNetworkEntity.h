//
//  YUNetworkEntity.h
//  YUNetworking
//
//  Created by duan on 14-9-23.
//  Copyright (c) 2014年 duan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    YUNetworkingResult_Success,
    YUNetworkingResult_Fail
} YUNetworkingResult;

@interface YUNetworkEntity : NSObject

+(YUNetworkEntity*)networkEntity:(id)requestTarget url:(NSString*)requestUrl type:(NSInteger)requestType parameters:(NSDictionary*)requestParameters name:(NSString*)requestName selector:(SEL)selector;

@property(nonatomic,strong,readonly) NSString* requestID;


@property(nonatomic,assign) id requestTarget;
@property(nonatomic,strong) NSString* requestUrl;
@property(nonatomic) NSInteger requestType;
@property(nonatomic,strong) NSDictionary* requestParameters;
@property(nonatomic) SEL requestSel;
@property(nonatomic,strong) NSString* requestName;

@property(nonatomic) id returnObj;
@property(nonatomic) YUNetworkingResult requestResult;
@property(nonatomic) NSError* error;

@property(nonatomic) NSString *startTime;
@property(nonatomic) NSTimeInterval  startTimeInterval;
@property(nonatomic) NSTimeInterval  useTimeInterval;
@property(nonatomic,strong) NSString*  logPath;

-(NSDictionary*)porpertyDictionary;

@end
