//
//  ServiceXpcServer.h
//  XPC_DEMO
//
//  Created by 翁黄格 on 2022/2/12.
//

#import <Foundation/Foundation.h>
#import "XPCServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServiceXpcServer : NSObject<NSXPCListenerDelegate, ProviderCommunication>

//单例模式
+(instancetype)shared;

//开始监听
- (void)startListener;

- (void)promptUser:(NSDictionary *)flowInfo completion:(void (^)(int))respnseHandle;

@end

NS_ASSUME_NONNULL_END
