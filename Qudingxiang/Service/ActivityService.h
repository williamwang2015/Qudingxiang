//
//  ActivityService.h
//  趣定向
//
//  Created by Prince on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityService : NSObject
+ (void)cellDataBlock:(void (^)(NSDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey andWithCurr:(NSString *)curr;

@end
