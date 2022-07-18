//
//  main.m
//  RunLoop_Demo
//
//  Created by 翁黄格 on 2022/7/17.
//

#import <Foundation/Foundation.h>

@interface RunLoopLearn : NSObject

- (void)TestRunLoopLifeCircle;

@end

@implementation RunLoopLearn

/**
 * @breif runLoop生命周期
 */
void RunLoopLifeCircle(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    switch(activity) {
        //即将进入Loop
        case kCFRunLoopEntry:
            NSLog(@"run loop entry");
            break;
        //即将处理 Timer
        case kCFRunLoopBeforeTimers:
            NSLog(@"run loop before timers");
            break;
        //即将处理 Source
        case kCFRunLoopBeforeSources:
            NSLog(@"run loop before sources");
            break;
        //即将进入休眠
        case kCFRunLoopBeforeWaiting:
            NSLog(@"run loop before waiting");
            break;
        //刚从休眠中唤醒
        case kCFRunLoopAfterWaiting:
            NSLog(@"run loop after waiting");
            break;
        //即将退出Loop
        case kCFRunLoopExit:
            NSLog(@"run loop exit");
            break;
        default:
            break;
    }
}

//执行
-(void)message:(NSTimer *)timer{
    NSLog(@"hello...");
}

- (void)TestRunLoopLifeCircle {
    //创建observer
    CFRunLoopObserverContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,kCFRunLoopAllActivities, YES, 0, &RunLoopLifeCircle, &context);
    //添加observer到runloop
    CFRunLoopAddObserver([[NSRunLoop currentRunLoop] getCFRunLoop], observer, kCFRunLoopDefaultMode);
    
    //事件产生才会会触发RunLoop
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(message:) userInfo:nil repeats:YES];
    
    //运行runloop
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    
}
@end

int main(int argc, const char * argv[]) {
    [[[RunLoopLearn alloc] init] TestRunLoopLifeCircle];
    dispatch_main();
    return 0;
}
