//
//  HPTestHelper.h
//  Live Link
//
//  Created by Live Paper on 7/30/15.
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface HPTestHelper : NSObject

/**
 Swaps the implementations of two class methods on a given class

 @param cls Class of object implementing methods to be swapped
 @param selectorOne One of the selectors to use in the swap
 @param selectorTwo The other selector to use in the swap
 */
+ (void) swapClassMethodsForClass:(Class)cls selectorOne:(SEL)selectorOne selectorTwo:(SEL)selectorTwo;

/**
 Swaps the implementations of two instance methods on a given class
 @param cls Class of object implementing methods to be swapped
 @param selectorOne One of the selectors to use in the swap
 @param selectorTwo The other selector to use in the swap
 */
+ (void) swapInstanceMethodsForClass:(Class)cls selectorOne:(SEL)selectorOne selectorTwo:(SEL)selectorTwo;

@end
