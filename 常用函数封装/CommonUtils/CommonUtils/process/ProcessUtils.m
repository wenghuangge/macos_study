//
//  ProcessUtils.c
//  CommonUtils
//
//  Created by 翁黄格 on 2022/10/21.
//

#include "ProcessUtils.h"

/**
 *  @breif  执行shell命令
 *  @param  execute_path 命令路径
 *  @param  args         执行参数
 *  @return 命令结果
 */
NSString *execute_command(NSString *execute_path, NSArray *args) {
    NSTask *task = [[NSTask alloc] init];
    if (task == nil) return nil;
    //设置执行参数
    [task setLaunchPath: execute_path];
    [task setArguments:args];
    
    //初始化管道
    NSPipe *pipe = [NSPipe pipe];
    if (pipe == nil) return nil;
    
    //设置输出管道
    [task setStandardOutput:pipe];
    
    //获取管道句柄
    NSFileHandle *fileHandle = [pipe fileHandleForReading];
    if (fileHandle == nil) return nil;
    
    //启动进程
    [task launch];
    
    //读取数据
    NSData *data = [fileHandle readDataToEndOfFile];
    if (data == nil) return nil;
    
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return ret;
    
}
