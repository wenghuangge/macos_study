//
//  XPCMgr.m
//  XPC_CLIENT
//
//  Created by 翁黄格 on 2022/2/12.
//

#import "XPCMgr.h"

#define RECONNECT_DELAY_TIME 1      //重新连接的间隔时间

@interface XPCMgr()

//XPC连接
@property(nonatomic, strong) NSXPCConnection *connection;

//XPC运行状态
@property(assign) bool isXPCRunning;


//Xpc首次建立连接等待信号量
@property (retain) dispatch_semaphore_t xpcConnectSem;

//XPC需要进行重连信号量
@property(retain) dispatch_semaphore_t xpcTaskSem;

//XPC需要重联任务次数
@property(nonatomic, assign) int xpcConnectTaskSum;

//是否立即重连
@property(assign) bool isReconnectNow;

//XPC连接状态锁
@property(retain) NSLock *xpcStatusLock;

@end


@implementation XPCMgr
- (instancetype)init {
    if (self = [super init]) {
        _xpcStatusLock = [[NSLock alloc] init];
    }
    return self;
}

//单例模式
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static XPCMgr *shared;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

# pragma mark - XPC
//XPC连接任务循环,有重连任务时唤醒，进行xpc连接
- (void)xpcRunLoop {
    while (self.isXPCRunning) {
        //任务执行标志
        bool runFlag = NO;
        @synchronized (self.connection) {
            if (self.xpcConnectTaskSum > 0) {
                runFlag = YES;
                self.xpcConnectTaskSum--;
            }
        }
        if (runFlag) {
            [self xpcConnectTaskRun];
        } else {
            //等待任务
            dispatch_semaphore_wait(self.xpcTaskSem, DISPATCH_TIME_FOREVER);
        }
    }
}

//启动XPC任务连接线程
- (void)startXPCTaskRAunloop {
    
    [self.xpcStatusLock lock];
    if (self.isXPCRunning) {
        [self.xpcStatusLock unlock];
        return;
    }
    
    //设置初始任务
    @synchronized (self.connection) {
        self.xpcConnectTaskSum = 0;
    }
    
    //初次XPC连接
    [self xpcConnectTaskRun];
    
    NSLog(@"start xpc connection task run loop");
    self.xpcTaskSem = dispatch_semaphore_create(0);
    self.isReconnectNow = YES;
    self.isXPCRunning = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self xpcRunLoop];
    });
    
    [self.xpcStatusLock unlock];
}

//停止XPC连接任务线程
- (void)stopXPCTaskRunloop {
    [self.xpcStatusLock lock];
    if (!self.isXPCRunning) {
        [self.xpcStatusLock unlock];
        return;
    }
    
    self.isXPCRunning = NO;
    NSLog(@"stop xpc connection task run loop");
    dispatch_semaphore_signal(self.xpcTaskSem);
    //断开XPC连接
    [self closeXPCConnect];
    [self.xpcStatusLock unlock];
}


//断开XPC连接
- (int)closeXPCConnect {
    NSLog(@"try to close xpc connection");
    if (nil != self.connection) {
        [self.connection invalidate];
    }
    self.connection = nil;
    return EXECUTE_SUCCESS;
}


//XPC连接任务执行
- (void)xpcConnectTaskRun {
    NSLog(@"xpc connect task run...");
    //尝试进行xpc连接
    [self createXPCConnect];
    if ([self setExportProtocol] != 0) {
        //连接失败
        [self closeXPCConnect];
    } else {
        //连接成功, 回调通知
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.clientCallBack(XPC_RECONNECTION, NULL);
        });
        @synchronized (self.connection) {
            //清空重连任务
            self.xpcConnectTaskSum = 0;
        }
        
    }
}

//建立xpc连接
- (void)createXPCConnect {
    if (nil != self.connection) {
        return;
    }
    NSLog(@"try to create connect....");
    self.connection = [[NSXPCConnection alloc] initWithMachServiceName:@DEMO_SERVICE_MACH_SERVICE options:(NSXPCConnectionPrivileged)];
    
    //设置导入接口
    self.connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ServiceProtocol)];
    //设置导出接口
    self.connection.exportedInterface = nil;
    //设置导出接口实现
    self.connection.exportedObject = nil;
    
    __weak typeof(self) weakSelf = self;
    
    //连接断开
    self.connection.invalidationHandler = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf xpcTearDown];
        NSLog(@"xpc connection has been invalidated");
    };
    
    //连接中断
    self.connection.interruptionHandler = ^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf xpcTearDown];
        NSLog(@"xpc connection has been interrupt");
    };
    
    //开始运行
    [self.connection resume];
}

//XPC连接断开
- (void)xpcTearDown {
    NSLog(@"connection tead down");
    if(nil != self.xpcConnectSem) {
        //需要重连信号
        dispatch_semaphore_signal(self.xpcConnectSem);
    }
    //开始重连
    NSLog(@"xpc connection is ReconnectionNow:%d", self.isReconnectNow);
    //判断是否立即重联
    if (self.isReconnectNow) {
        [self xpcAddConnectTask];
        self.isReconnectNow = NO;
    } else {
        //延时重联
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(RECONNECT_DELAY_TIME * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            [self xpcAddConnectTask];
        });
    }
}

//XPC添加连接任务
- (void)xpcAddConnectTask {
    if (self.isXPCRunning) {
        @synchronized (self.connection) {
            if (0 == self.xpcConnectTaskSum) {
                dispatch_semaphore_signal(self.xpcTaskSem);
            }
            self.xpcConnectTaskSum++;
        }
    }
}

//xpc进行首次连接通信
- (int)setExportProtocol {
    self.xpcConnectSem = dispatch_semaphore_create(0);
    __block int receiveStatus = -1;
    __weak typeof(self) weakSelf = self;
    [self.connection.remoteObjectProxy setRemoteProtocol:@"lianjie..." completion:^(int receive) {
        __strong typeof(self) strongSelf = weakSelf;
        receiveStatus = receive;
        //停止等待
        dispatch_semaphore_signal(strongSelf.xpcConnectSem);
    }];
    //等待执行结果消息
    dispatch_semaphore_wait(self.xpcConnectSem, DISPATCH_TIME_FOREVER);
    NSLog(@"setExportProtocol received res: %d", receiveStatus);
    self.xpcConnectSem = nil;
    return receiveStatus;
}

@end
