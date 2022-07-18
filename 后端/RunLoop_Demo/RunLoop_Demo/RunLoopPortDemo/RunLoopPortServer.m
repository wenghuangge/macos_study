//
//  RunLoopPortServer.m
//  RunLoop_Demo
//
//  Created by 翁黄格 on 2022/7/18.
//

#import "RunLoopPortServer.h"
#import "RunLoopCommon.h"
#import "RunLoopPortClient.h"

@interface RunLoopPortServer()<NSMachPortDelegate>
@end

@implementation RunLoopPortServer

- (void)launchServer {
    //分配端口
    NSPort *port = [NSMachPort port];
    [port setDelegate:self];
    //添加端口监听
    [[NSThread currentThread] setName:@"runLoop server thread"];
    [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
    
    //开启通信线程
    RunLoopPortClient *client = [[RunLoopPortClient alloc] init];
    [NSThread detachNewThreadSelector:@selector(launchClientWithPort:) toTarget:client withObject:port];
    
    [[NSRunLoop currentRunLoop] run];

}

// 回调函数
- (void)handlePortMessage:(NSPortMessage *)message {
    //消息解析
    unsigned int msgId = message.msgid;
    NSArray *arr = [message.components copy];
    NSString *str = nil;
    NSPort *remotePort = message.sendPort;
    NSPort *localPort  = message.receivePort;
    NSLog(@"msgId:%d", msgId);
    if (arr.count > 0) {
        str = [[NSString alloc] initWithData:arr[0] encoding:NSUTF8StringEncoding];
        NSLog(@"receive msg:%@", str);
    }
    //发送消息给子线程
    [remotePort sendBeforeDate:[NSDate date] components:nil from:localPort reserved:0];
}
@end

int main() {
    RunLoopPortServer *server = [[RunLoopPortServer alloc] init];
    [server launchServer];
}
