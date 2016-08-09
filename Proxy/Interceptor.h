//
//  Proxy.h
//  TemplateKit
//
//  Created by Matias Cudich on 8/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Interceptor : NSObject

- (nonnull instancetype)initWithTarget:(nullable id<NSObject>)target interceptor:(nullable id<NSObject>)interceptor protocol:(nonnull Protocol *)aProtocol;

- (void)registerInterceptableSelector:(nonnull SEL)selector;

@end
