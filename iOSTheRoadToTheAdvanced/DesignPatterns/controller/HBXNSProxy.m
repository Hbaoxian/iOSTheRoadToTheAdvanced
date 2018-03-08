//
//  HBXNSProxy.m
//  iOSTheRoadToTheAdvanced
//
//  Created by 黄保贤 on 2018/3/8.
//  Copyright © 2018年 黄保贤. All rights reserved.
//

#import "HBXNSProxy.h"
#import "AbostrctStargeteMessage.h"
#import <objc/runtime.h>
#import <objc/message.h>


@implementation HBXNSProxy

/*
 * 配发消息
 */
- (void)forwardInvocation:(NSInvocation *)invocation {
   //获取sel
    SEL selector = [invocation selector];

    // 判断
    if ([self.delegate respondsToSelector:selector]) {
        [invocation setTarget:self.delegate];
        //执行方法 排发方法
        [invocation invoke];
    }else {
        // 获取参数
        NSString *selector = NSStringFromSelector(invocation.selector);
        //获取类
        const char *className =  class_getName([self class]);
        NSArray *paramter = nil;
        if (self.delegate) {
            paramter = @[[NSString stringWithFormat:@"%@",className],[NSString stringWithFormat:@"%@",selector]];
        }
        
        [invocation setArgument:&paramter atIndex:2];
        
        
        
        // 替换
        invocation.selector = NSSelectorFromString(@"emptMessageHandle:");
        //再去回去获取单列对象
        AbostrctStargeteMessage * handle = [AbostrctStargeteMessage instance] ;
        //设置代理
        [invocation setTarget:handle];
        //执行
        [invocation invoke];
    }
    
    
    
}

/*
 * 消息签名
 */
- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    // 如果支持这个消息，就将这个方法签名返回去
    if ([self.delegate respondsToSelector:sel]) {
        return [self.delegate methodSignatureForSelector:sel];
    }else {
        AbostrctStargeteMessage * handle = [AbostrctStargeteMessage instance] ;
        return [handle methodSignatureForSelector:NSSelectorFromString(@"emptMessageHandle:")];
    }
    
}


@end
