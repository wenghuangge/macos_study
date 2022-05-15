//
//  main.m
//  Extension
//
//  Created by 翁黄格 on 2022/5/15.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import "ServiceXpcServer.h"
int main(int argc, char *argv[])
{
    @autoreleasepool {
        [NEProvider startSystemExtensionMode];
        [[ServiceXpcServer shared] startListener];
    }
    
    dispatch_main();
}
