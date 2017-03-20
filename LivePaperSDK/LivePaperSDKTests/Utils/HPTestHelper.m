//
//  HPTestHelper.m
//  Live Link
//
//  Created by Live Paper on 7/30/15.
//  Copyright (c) 2015 HP. All rights reserved.
//

#import "HPTestHelper.h"

@implementation HPTestHelper

+ (void)swapClassMethodsForClass:(Class)cls selectorOne:(SEL)selectorOne selectorTwo:(SEL)selectorTwo {
    Method method1 = class_getClassMethod(cls, selectorOne);
    Method method2 = class_getClassMethod(cls, selectorTwo);
    method_exchangeImplementations(method1, method2);
}

+ (void)swapInstanceMethodsForClass:(Class)cls selectorOne:(SEL)selectorOne selectorTwo:(SEL)selectorTwo {
    Method method1 = class_getInstanceMethod(cls, selectorOne);
    Method method2 = class_getInstanceMethod(cls, selectorTwo);
    method_exchangeImplementations(method1, method2);
}

@end
