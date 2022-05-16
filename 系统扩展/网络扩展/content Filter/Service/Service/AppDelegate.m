//
//  AppDelegate.m
//  Service
//
//  Created by 翁黄格 on 2022/5/15.
//

#import "AppDelegate.h"
#import <NetworkExtension/NetworkExtension.h>
#import <SystemExtensions/SystemExtensions.h>
#import "XPCClient.h"

NS_ENUM(NSInteger, Status) {
    stopped,
    indeterminate,
    running
};

@interface AppDelegate ()<OSSystemExtensionRequestDelegate>

//图标
@property (weak) IBOutlet NSImageView *statusIndicator;
//旋转状态
@property (weak) IBOutlet NSProgressIndicator *statusSpinner;
//开始按钮
@property (weak) IBOutlet NSButton *startbutton;
//结束按钮
@property (weak) IBOutlet NSButton *stopButton;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;


//window窗口
@property (strong) IBOutlet NSWindow *window;
//扩展运行状态
@property (nonatomic, assign) enum Status status;
//系统扩展
@property (strong) OSSystemExtensionRequest *currentRequest;
@property (strong) XPCClient *client;
//filter变换监控
@property (strong) id observe;
@end

@implementation AppDelegate

#pragma mark - "生命周期"
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //初始化为未启动状态
    self.status = indeterminate;
    
    //获取网络过滤器状态
    [self loadFilterConfiguration:^(int success) {
        if (!success) {
            self.status = stopped;
            return;
        }
        [self updateStatus];
        
        //添加监控
        self.observe = [NSNotificationCenter.defaultCenter addObserverForName:NEFilterConfigurationDidChangeNotification object:[NEFilterManager sharedManager] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self updateStatus];
        }];
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    if (self.observe == nil) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.observe name:NEFilterConfigurationDidChangeNotification object:[NEFilterManager sharedManager]];
}

- (void)setStatus:(enum Status)status {
    //修改运行状态
    switch (status) {
        //停止状态
        case stopped:
            [self.statusIndicator setImage:[NSImage imageNamed:@"dot_red"]];
            [self.statusSpinner stopAnimation:self];
            [self.statusSpinner setHidden:true];
            [self.stopButton setHidden:true];
            [self.startbutton setHidden:false];
            break;
        //未决策
        case indeterminate:
            [self.statusIndicator setImage:[NSImage imageNamed:@"dot_yellow"]];
            [self.statusSpinner startAnimation:self];
            [self.statusSpinner setHidden:false];
            [self.stopButton setHidden:true];
            [self.startbutton setHidden:true];
            break;
        //运行状态
        case running:
            [self.statusIndicator setImage:[NSImage imageNamed:@"dot_green"]];
            [self.statusSpinner stopAnimation:self];
            [self.statusSpinner setHidden:true];
            [self.stopButton setHidden:false];
            [self.startbutton setHidden:true];
        default:
            break;
    }
}

//更新状态
- (void)updateStatus {
    if ([[NEFilterManager sharedManager] isEnabled]) {
        [self registerWithProvider];
    } else {
        self.status = stopped;
    }
}

//建立连接
- (void)registerWithProvider {
    [[XPCClient sharedInstance] register:^(bool success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.status = success ? running: stopped;
        });
    }];
    //添加代理
    [[XPCClient sharedInstance] setDelegate:self];
    NSLog(@"aa");
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

//开启流量过滤
- (void)enableFilterConfiguration {
    NEFilterManager *filterManager = [NEFilterManager sharedManager];
    if (filterManager.isEnabled) {
        [self registerWithProvider];
        return;
    }
    
    [self loadFilterConfiguration:^(int success) {
        if (success != true) {
            self.status = stopped;
            return;
        }
        
        //设置过滤配置
        if(filterManager.providerConfiguration == nil) {
            NEFilterProviderConfiguration *provideConfiguration = [[NEFilterProviderConfiguration alloc] init];
            provideConfiguration.filterSockets = true;
            provideConfiguration.filterPackets = false;
            filterManager.providerConfiguration = provideConfiguration;
        }
        //开启流量过滤
        filterManager.enabled = true;
        [filterManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil ) {
                    NSLog(@"Failed to save the filterConfiguration: %@", error);
                    self.status = stopped;
                    return;
                }
            });
            
        }];
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
    
    NSLog(@"Request to activate %@ failed with error %@.", request.identifier, error);
    self.status = stopped;
    self.currentRequest = nil;
}

//加载系统扩展完成回调
- (void)request:(nonnull OSSystemExtensionRequest *)request didFinishWithResult:(OSSystemExtensionRequestResult)result {
    
    if (result != OSSystemExtensionRequestCompleted) {
        NSLog(@"Unexpected result for system extension request");
        self.status = stopped;
        return;
    }
    
    //初始化网络配置
    [self enableFilterConfiguration];
}

//请求允许加载系统扩展
- (void)requestNeedsUserApproval:(nonnull OSSystemExtensionRequest *)request {
    NSLog(@"Extension %@ requires user approval", request.identifier);
}

#pragma mark - "action"
- (IBAction)startExtension:(id)sender {
    
    self.status = indeterminate;
    //已注册
    if ([[NEFilterManager sharedManager] isEnabled]) {
        [self registerWithProvider];
        return;
    }
    //已初始化
    if (self.currentRequest) {
        NSBeep();
        return;
    }
    
    //加载系统扩展
    NSLog(@"Beginning to install the extension");
    OSSystemExtensionRequest *req = [OSSystemExtensionRequest activationRequestForExtension:extensionIdentifity queue:dispatch_get_main_queue()];
    req.delegate = (id<OSSystemExtensionRequestDelegate>)self;
    [[OSSystemExtensionManager sharedManager] submitRequest:req];
    self.currentRequest = req;
    
}

- (IBAction)stopExtension:(id)sender {
    NEFilterManager *filterManager = [NEFilterManager sharedManager];
    self.status = indeterminate;
    //已经停止
    if (![filterManager isEnabled]) {
        self.status = stopped;
        return;
    }
    //停止content filter configuration
    filterManager.enabled = false;
    
    [self loadFilterConfiguration:^(int success) {
        if (!success) {
            self.status = stopped;
            return;
        }
        [[NEFilterManager sharedManager] setEnabled:false];
        [filterManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Failed to disable the filter configuration: %@", error.localizedDescription);
                    self.status = running;
                    return;
                }
        }];
        self.status = stopped;
    }];
}

- (void)logFlow:(NSDictionary *)flowInfo {
    NSString *localport = [flowInfo objectForKey:@"port"];
    NSString *address = [flowInfo objectForKey:@"remoteAddress"];
    NSFont *font = [NSFont userFixedPitchFontOfSize:12];
    
    NSMutableDictionary *logAttributes = [NSMutableDictionary dictionary];
    logAttributes[NSForegroundColorAttributeName] = [NSColor textColor];
    logAttributes[NSFontAttributeName] = font;
    
    //时间
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formater stringFromDate:[NSDate date]];
    NSString *message = [NSString stringWithFormat:@"date:%@ localPort:%@ <- remoteAddress:%@ \n",dateString, localport, address];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:message attributes:logAttributes];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.logTextView.textStorage appendAttributedString:attributedString];
    });
}
    
- (void)promptUser:(NSDictionary *)flowInfo completion:(void (^)(int))responseHandle {
    [self logFlow:flowInfo];
}

@end
