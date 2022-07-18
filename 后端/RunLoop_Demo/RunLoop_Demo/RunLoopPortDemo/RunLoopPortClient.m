//
//  RunLoopPortClient.m
//  RunLoop_Demo
//
//  Created by 翁黄格 on 2022/7/18.
//

#import "RunLoopPortClient.h"
#import "RunLoopCommon.h"

@interface RunLoopPortClient() <NSMachPortDelegate> {
    NSPort *remotePort;
    NSPort *localPort;
}

@end

@implementation RunLoopPortClient

- (void)launchClientWithPort:(NSPort *)port {
    //设置server端口
    remotePort = port;
    //设置线程名字
    [[NSThread currentThread] setName:@"RunLoop client"];
    //创建本地监听端口
    localPort = [NSPort port];
    //设置代理
    localPort.delegate = self;
    //添加端口监听
    [[NSRunLoop currentRunLoop] addPort:localPort forMode:NSDefaultRunLoopMode];
    //发送消息
    [self sendMessage];
    //开启runLoop
    [[NSRunLoop currentRunLoop] run];
}

//测试-发送消息
- (void)sendMessage {
    //构造数据
    NSString *str = @"hello world";
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:@[[str dataUsingEncoding:NSUTF8StringEncoding]]];
    //发送消息
    [remotePort sendBeforeDate:[NSDate date] msgid:kMsg components:array from:localPort reserved:0];
}

//端口监听回调函数
- (void)handlePortMessage:(NSPortMessage *)message {
    NSLog(@"receive message from parent thread");
}


@end
