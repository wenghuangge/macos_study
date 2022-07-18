//
//  Timer.m
//  RunLoop_Demo
//
//  Created by 翁黄格 on 2022/7/17.
//

#import <Foundation/Foundation.h>

//
//  main.m
//  RunLoop_Demo
//
//  Created by 翁黄格 on 2022/7/17.
//


//RunLoop定时器使用
@interface RunLoopLearn : NSObject
- (void)TestTimer;
@end

@implementation RunLoopLearn

- (void)Message {
    NSLog(@"....");
}

- (void)TestTimer {
    //创建定时器
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(Message) userInfo:nil repeats:YES];
    //启动runloop
    [[NSRunLoop currentRunLoop] run];
}

@end

int main(int argc, const char * argv[]) {
    RunLoopLearn *demo =  [[RunLoopLearn alloc] init];
    [demo TestTimer];
    return 0;
}
