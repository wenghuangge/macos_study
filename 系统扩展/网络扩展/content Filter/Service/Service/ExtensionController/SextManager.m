//
//  SextManager.m
//  Extension_Study
//
//  Created by 翁黄格 on 2022/5/14.
//

#import "SextManager.h"
#import <NetworkExtension/NetworkExtension.h>

@interface SextManager()<OSSystemExtensionRequestDelegate>

@property (strong) OSSystemExtensionRequest *currentRequest;

@end

@implementation SextManager

#pragma mark - "生命周期"
//单例
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static SextManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[SextManager alloc] init];
    });
    return manager;
}

//初始化
- (instancetype)init {
    if (self = [super init]) {
        self.currentRequest = nil;
    }
    return self;
}

#pragma mark - "网络扩展配置"
//Content Filter Configuration Manager
- (void) loadFilterConfiguration:(void(^)(int))completionHandle {
    [[NEFilterManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                bool success = true;
                if (error) {
                    success = false;
                    NSLog(@"Failed to load the filter configuration: %@", error);
                }
                completionHandle(success);
            });
    }];
}

#pragma mark - "系统扩展生命周期"
//启动系统扩展
- (void)startSextExtension {
    if (self.currentRequest) {
        NSBeep();
        return;
    }
    NSLog(@"Beginning to install the extension");
    
    OSSystemExtensionRequest *req = [OSSystemExtensionRequest activationRequestForExtension:extensionIdentifity queue:dispatch_get_main_queue()];
    
    req.delegate = (id<OSSystemExtensionRequestDelegate>)self;
    
    [[OSSystemExtensionManager sharedManager] submitRequest:req];
    self.currentRequest = req;
}

//替换系统扩展 检测到版本不一致的系统可扩展
- (OSSystemExtensionReplacementAction)request:(nonnull OSSystemExtensionRequest *)request actionForReplacingExtension:(nonnull OSSystemExtensionProperties *)existing withExtension:(nonnull OSSystemExtensionProperties *)ext {
    
    NSLog(@"Got the upgrade request (%@ -> %@); answering replace.", existing.bundleVersion, ext.bundleVersion);
    return OSSystemExtensionReplacementActionReplace;
}

//错误回调
- (void)request:(nonnull OSSystemExtensionRequest *)request didFailWithError:(nonnull NSError *)error {
    
    if (request != self.currentRequest) {
        NSLog(@"UNEXPECTED NON-CURRENT Request to activate %@ failed with error %@.", request.identifier, error.localizedDescription);
        return;
    }
    NSLog(@"Request to activate %@ failed with error %@.", request.identifier, error);
    self.currentRequest = nil;
}

//加载系统扩展完成回调
- (void)request:(nonnull OSSystemExtensionRequest *)request didFinishWithResult:(OSSystemExtensionRequestResult)result {
    if (request != self.currentRequest) {
        NSLog(@"UNEXPECTED NON-CURRENT Request to activate %@ succeeded.", request.identifier);
        return;
    }
    NSLog(@"Request to activate %@ succeeded (%zu).", request.identifier, (unsigned long)result);
    NSLog(@"Successfully installed the extension ✅\n");
    
    //初始化网络配置
   
}

//请求允许加载系统扩展
- (void)requestNeedsUserApproval:(nonnull OSSystemExtensionRequest *)request {
    NSLog(@"Extension %@ requires user approval", request.identifier);
}
@end
