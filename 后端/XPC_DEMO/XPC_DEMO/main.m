//
//  main.m
//  XPC_DEMO
//
//  Created by 翁黄格 on 2022/2/12.
//

#import <Cocoa/Cocoa.h>
#import <pthread.h>
#import "ServiceXpcServer.h"

pthread_t g_initThread = NULL;

/// 守护进程模块初始化线程
/// @param para 未使用
void* initThread(void* para){
    
    //XPC服务启动并开始监听接入
    [[ServiceXpcServer shared] startListener];
    NSLog(@"XPC listener Ready to work!");

    //线程自身detach处理
    if (g_initThread != NULL) {
        pthread_detach(g_initThread);
        g_initThread = NULL;
    }
    
    return NULL;
}

int main(int argc, const char * argv[]) {
    NSLog(@"start service......");
    pthread_attr_t  attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr,  PTHREAD_CREATE_DETACHED);
    //防止阻塞NSApplicationMain函数、创建可detach的线程进行业务初期化
    pthread_create(&g_initThread, &attr, initThread, NULL);
    
    
    return NSApplicationMain(argc, argv);
}
