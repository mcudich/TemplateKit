//
//  Proxy.h
//  TemplateKit
//
//  Created by Matias Cudich on 8/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Interceptor : NSProxy
- (instancetype)initWithTarget:(id<NSObject>)target interceptor:(id)interceptor;
@end
