//
//  main.m
//  XPC_CLIENT
//
//  Created by 翁黄格 on 2022/2/12.
//

#import <Foundation/Foundation.h>
#import "XPCServiceProtocol.h"
#import "XPCMgr.h"

//回调函数
int callback(const int event, void* ptr) {
    switch (event) {
        case XPC_RECONNECTION:
            NSLog(@"client call back: XPC reconnection");
            break;
            
        default:
            break;
    }
    return 0;
}

int main(int argc, const char * argv[]) {
    XPCMgr *xpcMgr = [[XPCMgr alloc] init];
    [xpcMgr setClientCallBack:callback];
    [xpcMgr startXPCTaskRAunloop];
    dispatch_main();
    return 0;
}
