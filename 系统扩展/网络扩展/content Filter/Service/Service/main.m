//
//  main.m
//  Service
//
//  Created by 翁黄格 on 2022/5/15.
//

#import <Cocoa/Cocoa.h>
#import <pthread.h>
#import "SextManager.h"


//启动线程
void* initThread(void *args) {
    [[SextManager shared] startSextExtension];
    return NULL;
}

int main(int argc, const char * argv[]) {
//    pthread_t thread;
//    pthread_create(&thread, NULL, initThread, NULL);
//    pthread_detach(thread);
    
    return NSApplicationMain(argc, argv);
}

