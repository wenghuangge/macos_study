//
//  FilterDataProvider.m
//  Extension
//
//  Created by 翁黄格 on 2022/5/15.
//

#import "FilterDataProvider.h"
#import "ServiceXpcServer.h"

@implementation FilterDataProvider

- (void)startFilterWithCompletionHandler:(void (^)(NSError *error))completionHandler {
    // Add code to initialize the filter
    NSLog(@"startFilterWithCompletionHandler");
    //网络规则
    NENetworkRule *netWorkrule = [[NENetworkRule alloc] initWithRemoteNetwork:nil remotePrefix:0 localNetwork:nil localPrefix:0 protocol:NENetworkRuleProtocolAny direction:NETrafficDirectionAny];
    
    //过滤器设置
    NEFilterRule *filterRule = [[NEFilterRule alloc] initWithNetworkRule:netWorkrule action:NEFilterActionFilterData];
    
    NSArray<NEFilterRule *> *ruleArray = [[NSArray alloc] initWithObjects:filterRule, nil];
    
    
    NEFilterSettings *filterSetting = [[NEFilterSettings alloc] initWithRules:ruleArray defaultAction:NEFilterActionAllow];
    
    //设置过滤器
    [self applySettings:filterSetting completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Failed to apply filter settring: %@", error.localizedDescription);
            }
            completionHandler(error);
    }];
}

- (void)stopFilterWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
    // Add code to clean up filter resources.
    completionHandler();
}

- (NEFilterNewFlowVerdict *)handleNewFlow:(NEFilterFlow *)flow {
    // Add code to determine if the flow should be dropped or not, downloading new rules if required.
    
    NEFilterSocketFlow *socketFlow = (NEFilterSocketFlow *)flow;
    NWEndpoint *localEndpoint = socketFlow.localEndpoint;
    NWEndpoint *remoteEndpoint = socketFlow.remoteEndpoint;
    NSLog(@"Got a new flow with local endpoint %@, remote endpoint %@", localEndpoint, remoteEndpoint);
    
   
    NWHostEndpoint *localhostEndpoint = (NWHostEndpoint *)localEndpoint;
    NWHostEndpoint *remoteHostEndPoint = (NWHostEndpoint *)remoteEndpoint;
    NSDictionary *flowInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[localhostEndpoint port],@"port", [remoteHostEndPoint hostname], @"remoteAddress",nil];
    
    [[ServiceXpcServer shared] promptUser:flowInfo completion:^(int action) {
            NSLog(@"ccccc");
    }];
    return [NEFilterNewFlowVerdict allowVerdict];
}

- (NEFilterDataVerdict *)handleInboundDataFromFlow:(NEFilterFlow *)flow readBytesStartOffset:(NSUInteger)offset readBytes:(NSData *)readBytes {
    // Add code to process the data and return the appropriate verdict.
    NSLog(@"handleInboundDataFromFlow");
    return [NEFilterDataVerdict allowVerdict];
}

- (NEFilterDataVerdict *)handleOutboundDataFromFlow:(NEFilterFlow *)flow readBytesStartOffset:(NSUInteger)offset readBytes:(NSData *)readBytes {
    // Add code to process the data and return the appropriate verdict.
    NSLog(@"handleOutboundDataFromFlow");
    return [NEFilterDataVerdict allowVerdict];
}

- (NEFilterDataVerdict *)handleInboundDataCompleteForFlow:(NEFilterFlow *)flow {
    // Add code to make a final decision about the flow.
    return [NEFilterDataVerdict allowVerdict];
}

- (NEFilterDataVerdict *)handleOutboundDataCompleteForFlow:(NEFilterFlow *)flow {
    // Add code to make a final decision about the flow.
    return [NEFilterDataVerdict allowVerdict];
}

@end
