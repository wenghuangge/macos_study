//
//  AppDelegate.h
//  Service
//
//  Created by 翁黄格 on 2022/5/15.
//

#import <Cocoa/Cocoa.h>
#import "XPCServiceProtocol.h"

#define extensionIdentifity @"com.wenghuangge.com.Service.systemextension"


@interface AppDelegate : NSObject <NSApplicationDelegate, AppCommunication>


@end

