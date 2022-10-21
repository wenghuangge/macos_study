//
//  ProcessUtils.h
//  CommonUtils
//
//  Created by 翁黄格 on 2022/10/21.
//

#ifndef ProcessUtils_h
#define ProcessUtils_h

#include <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  @breif  执行shell命令
 *  @param  execute_path 命令路径
 *  @param  args         执行参数
 *  @return 命令结果
 */
NSString *execute_command(NSString *execute_path, NSArray *args);


#ifdef __cplusplus
}
#endif

#endif /* ProcessUtils_h */
