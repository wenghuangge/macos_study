//
//  XPCMgr.h
//  XPC_CLIENT
//
//  Created by 翁黄格 on 2022/2/12.
//

#import <Foundation/Foundation.h>
#import "XPCServiceProtocol.h"
#import "AppDelegate.h"


NS_ASSUME_NONNULL_BEGIN

@interface XPCClient : NSObject
@property(nonatomic, strong)AppDelegate *delegate;
//初始化
- (instancetype)init;
//单例模式
+ (instancetype)sharedInstance;
//注册ipc
- (void)register:(void(^)(bool success))completionHandle;


@end

NS_ASSUME_NONNULL_END
