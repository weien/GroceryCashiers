//
//  Cashier.m
//  GroceryCashiers
//
//  Created by Weien Wang on 9/1/16.
//  Copyright © 2016 Weien Wang. All rights reserved.
//

#import "Cashier.h"

@implementation Cashier

- (instancetype)init {//WithRegisterNumber:(NSInteger)registerNumber {
    self = [super init];
    if (self) {
        self.customers = [NSMutableArray array];
        //self.registerNumber = registerNumber;
    }
    return self;
}

@end
