//
//  RunLoopPortClient.h
//  RunLoop_Demo
//
//  Created by 翁黄格 on 2022/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunLoopPortClient : NSObject

- (void)launchClientWithPort:(NSPort *)port;

@end

NS_ASSUME_NONNULL_END
