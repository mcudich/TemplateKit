//
//  Proxy.m
//  TemplateKit
//
//  Created by Matias Cudich on 8/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

#import "Interceptor.h"

@implementation Interceptor
  id __weak _interceptor;
  id <NSObject> __weak _target;

- (instancetype)initWithTarget:(id <NSObject>)target interceptor:(id)interceptor
{
  // -[NSProxy init] is undefined
  if (!self) {
    return nil;
  }

  _target = target ? : [NSNull null];
  _interceptor = interceptor;

  return self;
}
@end