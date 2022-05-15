//
//  SextManager.h
//  Extension_Study
//
//  Created by 翁黄格 on 2022/5/14.
//

#import <Cocoa/Cocoa.h>
#import <SystemExtensions/SystemExtensions.h>
NS_ASSUME_NONNULL_BEGIN

#define extensionIdentifity @"com.wenghuangge.com.Service.systemextension"


@interface SextManager : NSObject

//单例对象
+ (instancetype)shared;

//加载扩展
- (void)startSextExtension;

//获取系统已加载filter
- (void) loadFilterConfiguration:(void(^)(int))completionHandle;
@end

NS_ASSUME_NONNULL_END
