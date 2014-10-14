//
//  YUHTTPRequest.h
//  YUNetworking
//
//  Created by duan on 14-9-23.
//  Copyright (c) 2014年 duan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "AFURLResponseSerialization.h"
#import "AFURLRequestSerialization.h"
#import "AFSecurityPolicy.h"
#import "AFNetworkReachabilityManager.h"
#import "YUNetworkEntity.h"

@interface YUNetworking : NSObject

+(YUNetworking*)shareNetworking;

@property(nonatomic) BOOL networkLog;
@property(nonatomic) NSTimeInterval avgTime;

-(void)Get:(YUNetworkEntity*)networkEntity;
-(void)Post:(YUNetworkEntity*)networkEntity;

-(void)stop;

@end
