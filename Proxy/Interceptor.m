//
//  Proxy.m
//  TemplateKit
//
//  Created by Matias Cudich on 8/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

#import "Interceptor.h"

@implementation Interceptor
  id<NSObject> __weak _interceptor;
  id<NSObject> __weak _target;
  Protocol *_protocol;

  NSMutableSet *_selectors;

- (instancetype)initWithTarget:(id<NSObject>)target interceptor:(id<NSObject>)interceptor protocol:(nonnull Protocol *)aProtocol {
  if (!self) {
    return nil;
  }

  _target = target ? : [NSNull null];
  _interceptor = interceptor;
  _protocol = aProtocol;

  _selectors = [[NSMutableSet alloc] init];

  return self;
}

- (void)registerInterceptableSelector:(SEL)selector {
  [_selectors addObject:NSStringFromSelector(selector)];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
  return aProtocol == _protocol;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  if ([self interceptsSelector:aSelector]) {
    return [_interceptor respondsToSelector:aSelector];
  } else {
    return [_target respondsToSelector:aSelector];
  }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
  if ([self interceptsSelector:aSelector]) {
    return _interceptor;
  } else {
    return [_target respondsToSelector:aSelector] ? _target : nil;
  }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
  NSMethodSignature *methodSignature = nil;
  if ([self interceptsSelector:aSelector]) {
    methodSignature = [[_interceptor class] instanceMethodSignatureForSelector:aSelector];
  } else {
    methodSignature = [[_target class] instanceMethodSignatureForSelector:aSelector];
  }

  return methodSignature ?: [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  // If we are down here this means _interceptor and _target where nil. Just don't do anything to prevent a crash
}

- (BOOL)interceptsSelector:(SEL)selector {
  return [_selectors containsObject:NSStringFromSelector(selector)];
}

@end