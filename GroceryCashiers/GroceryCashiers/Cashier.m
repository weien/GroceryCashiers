//
//  Cashier.m
//  GroceryCashiers
//
//  Created by Weien Wang on 9/1/16.
//  Copyright © 2016 Weien Wang. All rights reserved.
//

#import "Cashier.h"

@implementation Cashier

- (instancetype)init {
    self = [super init];
    if (self) {
        self.customers = [NSMutableArray array];
    }
    return self;
}

@end
