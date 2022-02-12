//
//  XPCMgr.h
//  XPC_CLIENT
//
//  Created by 翁黄格 on 2022/2/12.
//

#import <Foundation/Foundation.h>
#import "XPCServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPCMgr : NSObject

@property(nonatomic) CLIENT_CALL_BACK clientCallBack;

- (instancetype)init;

//单例模式
+ (instancetype)sharedInstance;

//启动XPC任务连接线程
- (void)startXPCTaskRAunloop;

//停止XPC连接任务线程
- (void)stopXPCTaskRunloop;

@end

NS_ASSUME_NONNULL_END
