//
//  XPCServiceProtocol.h
//  XPC_DEMO
//
//  Created by 翁黄格 on 2022/2/12.
//

#ifndef XPCServiceProtocol_h
#define XPCServiceProtocol_h

#define DEMO_SERVICE_MACH_SERVICE "com.wenghuannge.com-service"

//定义函数返回值
typedef enum {
    EXECUTE_FAILURE                  = -1,        //执行失败
    EXECUTE_SUCCESS                  = 0,         //执行成功
}RETURN_STATUE;

//事件回调
typedef enum {
    XPC_RECONNECTION
}EVENT;

typedef struct{
    NSString *localPort;
    NSString *remoteAddress;
}FlowInfoKey;

/// Provider --> App IPC
@protocol AppCommunication
/**
 * 初次通信使用
 *
 * @param flowInfo 传入数据
 * @param respnseHandle 数据接收状态回调
 */
- (void)promptUser:(NSDictionary *)flowInfo completion:(void (^)(int))respnseHandle;

@end

/// App --> Provider IPC
@protocol ProviderCommunication

- (void)register:(void(^)(bool success))completionHandle;

@end

#endif /* XPCServiceProtocol_h */
