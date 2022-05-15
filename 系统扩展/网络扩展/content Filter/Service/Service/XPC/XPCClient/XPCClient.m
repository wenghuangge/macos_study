//
//  XPCMgr.m
//  XPC_CLIENT
//
//  Created by 翁黄格 on 2022/2/12.
//

#import "XPCClient.h"

@interface XPCClient()<AppCommunication>

//XPC连接
@property(nonatomic, strong) NSXPCConnection *connection;
@end


@implementation XPCClient

//单例模式
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static XPCClient *shared;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

//初始化
- (instancetype)init {
    if (self = [super init]) {
        self.connection = nil;
    }
    return self;
}

//创建连接
- (void)register:(void(^)(bool success))completionHandle {
    
    if (self.connection) {
        NSLog(@"Already registered with the provider");
        completionHandle(true);
    }
    self.connection = [[NSXPCConnection alloc] initWithMachServiceName:@DEMO_SERVICE_MACH_SERVICE options:NSXPCConnectionPrivileged];
    
    //设置导入接口
    self.connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ProviderCommunication)];
    //设置导出接口
    self.connection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(AppCommunication)];
    //设置导出接口实现
    self.connection.exportedObject = self;

    //连接断开
    self.connection.invalidationHandler = ^{
        NSLog(@"xpc connection has been invalidated");
        
    };
    
    //连接中断
    self.connection.interruptionHandler = ^{
        NSLog(@"xpc connection has been interrupt");
    };
    
    //resume
    [self.connection resume];
    
    //获取代理
    id providerProxy = [self.connection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
            NSLog(@"Failed to register with the provider: %@", error.localizedDescription);
            [self.connection invalidate];
            self.connection = nil;
            completionHandle(false);
    }];
    
    [providerProxy register:completionHandle];
    
}

- (void)promptUser:(NSDictionary *)flowInfo completion:(void (^)(int))respnseHandle {
    [self.delegate promptUser:flowInfo completion:respnseHandle];
}

@end
