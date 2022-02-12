//
//  ServiceXpcServer.m
//  XPC_DEMO
//
//  Created by 翁黄格 on 2022/2/12.
//

#import "ServiceXpcServer.h"
#import <libproc.h>

@interface ServiceXpcServer() <NSXPCListenerDelegate, ServiceProtocol>

@property (nonatomic, strong, readwrite) NSXPCListener *listener;

@end

@implementation ServiceXpcServer

- (id)init {
    if (self = [super init]) {
        self->_listener = nil;
    }
    return self;
}

//单例模式
+(instancetype)shared{
    static ServiceXpcServer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

//开始监听
- (void)startListener {
    //创建listener
    self.listener = [[NSXPCListener alloc] initWithMachServiceName:@DEMO_SERVICE_MACH_SERVICE];
    if (self.listener == nil) {
        NSLog(@"XPC Server listen failed!");
        return;
    }
    
    //监听
    self.listener.delegate = self;
    [self.listener resume];
}

//监听处理
- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    NSAssert(newConnection && listener && listener == self.listener, @"shouldAcceptNewConnection param failed");
    NSLog(@"start shouldAcceptNewConnection %@", newConnection);
    //获取client的进程PID
    pid_t pid = newConnection.processIdentifier;
    //获取进程名
    char bufferName[MAXPATHLEN] = {0};
    char bufferPath[PROC_PIDPATHINFO_MAXSIZE] = {0};
    
    if (0 == proc_pidpath(pid, bufferPath, PROC_PIDPATHINFO_MAXSIZE-1)) {
        //获取进程信息失败
        NSLog(@"get connect proc pid failed");
        return NO;
    }
    
    if (0 == proc_name(pid, bufferName, MAXPATHLEN-1)) {
        //获取进程信息失败
        NSLog(@"get connect procname failed");
        return NO;
    }
    
    newConnection.remoteObjectInterface = nil;
    //导出接口
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ServiceProtocol)];
    newConnection.exportedObject = self;
    
    newConnection.invalidationHandler = ^{
        NSLog(@"newConnection has been invalidate");
    };
    newConnection.interruptionHandler = ^{
        NSLog(@"newConnection has been interruptionHandler");
    };
    
    NSLog(@"client: %s", bufferName);
    [newConnection resume];
    
    return YES;
}

- (void)setRemoteProtocol:(NSString *)protocol completion:(void (^)(int))completion {
    NSLog(@"setRemoteProtocol %@", protocol);
    if (completion) {
        completion(0);
    }
}

@end
