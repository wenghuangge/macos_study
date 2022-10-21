//
//  ProcessUnitTest.m
//  ProcessUnitTest
//
//  Created by 翁黄格 on 2022/10/21.
//

#import <XCTest/XCTest.h>
#import "ProcessUtils.h"


@interface ProcessUnitTest : XCTestCase

@end

@implementation ProcessUnitTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)test_execute_command {
    NSArray *arguments = [NSArray arrayWithObjects: @"-l", @"/", nil];
    NSString *ret = execute_command(@"/bin/ls", arguments);
    NSLog(@"ret = %@", ret);
}

@end
