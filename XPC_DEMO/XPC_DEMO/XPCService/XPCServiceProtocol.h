//
//  XPCServiceProtocol.h
//  XPC_DEMO
//
//  Created by 翁黄格 on 2022/2/12.
//

#ifndef XPCServiceProtocol_h
#define XPCServiceProtocol_h

#define DEMO_SERVICE_MACH_SERVICE "com.xpcservice.demo"

//定义函数返回值
typedef enum {
    EXECUTE_FAILURE                  = -1,        //执行失败
    EXECUTE_SUCCESS                  = 0,         //执行成功
}RETURN_STATUE;

//事件回调
typedef enum {
    XPC_RECONNECTION
}EVENT;

//回调指针
typedef int (*CLIENT_CALL_BACK)(const int event, void *callbackPtr);

@protocol ServiceProtocol
/**
 * 初次通信使用
 *
 * @param protocol 导入协议名
 * @param completion 数据接收状态回调
 */
- (void)setRemoteProtocol:(NSString *)protocol completion:(void(^)(int receive))completion;

@end

#endif /* XPCServiceProtocol_h */
