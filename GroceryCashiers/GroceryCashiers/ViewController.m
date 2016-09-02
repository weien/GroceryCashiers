//
//  ViewController.m
//  GroceryCashiers
//
//  Created by Weien Wang on 9/1/16.
//  Copyright © 2016 Weien Wang. All rights reserved.
//

#import "ViewController.h"
#import "Cashier.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextView *mainTextView;
@property (strong, nonatomic) IBOutlet UIButton *goButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *goButtonHeightFromBottomConstraint;

@end

@implementation ViewController

#define kTypeA @"A"
#define kTypeB @"B"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void) keyboardWillShow:(NSNotification*)sender { //thanks http://swiftandpainless.com/adjust-for-the-keyboard-in-ios-using-swift/
    NSDictionary* userInfo = sender.userInfo;
    CGRect keyboardRect = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    self.goButtonHeightFromBottomConstraint.constant = CGRectGetHeight(keyboardRect) + 10;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}
- (IBAction)goButtonTapped:(id)sender {
    NSDictionary* output = [self runSimulationWithEntry:self.mainTextView.text];
    if ([output[@"success"] boolValue]) {
        [self showOutputMessage:[output[@"minutes"] integerValue]];
    }
    else {
        [self showErrorMessage:output[@"error"]];
    }
}

- (NSDictionary*) runSimulationWithEntry:(NSString*)entry {
    NSInteger latestArrivalTime = 0;
    BOOL traineeIsStartingNewItem = NO;
    
    NSMutableArray* rows = [[entry componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    if (rows.count < 2) {
        return @{@"success":@NO,@"error":NSLocalizedString(@"Please enter at least 2 rows.", nil)};
    }
    else {
        NSInteger numberOfCashiers = [rows.firstObject integerValue];
        NSMutableArray* cashiers = [NSMutableArray array];
        for (NSInteger n = 1; n <= numberOfCashiers; n++) {
            Cashier* cashier = [Cashier new];
            [cashiers addObject:cashier];
        }
        [rows removeObjectAtIndex:0];
        NSInteger currentTime = 0;
        
        for (NSString* customerRow in rows) { //do a couple things in advance of looping through time
            //check row fidelity
            NSArray* customerData = [customerRow componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (customerData.count != 3) {
                return @{@"success":@NO,@"error":NSLocalizedString(@"Each row should have exactly 3 items.", nil)};
            }
            
            //determine latestArrivalTime
            NSInteger arrivalTime = [[customerData objectAtIndex:1] integerValue];
            if (arrivalTime > latestArrivalTime) {
                latestArrivalTime = arrivalTime;
            }
        }
        
        while (YES) {
            //***PROCESSING EXISTING CUSTOMERS***
            for (Cashier* cashier in cashiers) {
                if (cashier.customers.count > 0) {
                    //Take training cashier into consideration
                    if ([cashier isEqual:cashiers.lastObject]) {
                        if (traineeIsStartingNewItem) {
                            traineeIsStartingNewItem = NO;
                            //trainee has finally finished the item! can do the below logic
                        }
                        else {
                            traineeIsStartingNewItem = YES;
                            break; //starting a new item -- can't do the below
                        }
                    }
                    
                    //Finish items and/or customers
                    NSInteger firstCustomerItemsRemaining = [cashier.customers.firstObject integerValue];
                    if (firstCustomerItemsRemaining == 1) {
                        [cashier.customers removeObjectAtIndex:0];
                    }
                    else {
                        firstCustomerItemsRemaining--;
                        [cashier.customers setObject:@(firstCustomerItemsRemaining) atIndexedSubscript:0];
                    }
                }
            }
            
            //**ADDING CUSTOMERS***
            for (NSString* customerRow in rows) {
                NSArray* customerData = [customerRow componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSInteger arrivalTime = [[customerData objectAtIndex:1] integerValue];
                
                //check if customer
                if (arrivalTime == currentTime) {
                    NSString* type = customerData.firstObject;
                    NSInteger numberOfItems = [customerData.lastObject integerValue];
                    if ([type isEqualToString:kTypeA]) {
                        NSArray* sortedCashiers = [cashiers sortedArrayUsingComparator:^NSComparisonResult(Cashier* obj1, Cashier* obj2) {
                            if (obj1.customers.count < obj2.customers.count) { //thanks http://stackoverflow.com/a/17498269/2284713
                                return NSOrderedAscending;
                            }
                            else if (obj1.customers.count > obj2.customers.count) {
                                return NSOrderedDescending;
                            }
                            else {
                                return NSOrderedSame;
                            }
                        }];
                        Cashier* cashierWithLeastCustomers = sortedCashiers.firstObject;
                        [cashierWithLeastCustomers.customers addObject:@(numberOfItems)];
                    }
                    else if ([type isEqualToString:kTypeB]) {
                        NSArray* emptyCashiers = [cashiers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customers.@count == 0"]];
                        if (emptyCashiers.count > 0) {
                            Cashier* firstEmptyCashier = emptyCashiers.firstObject;
                            [firstEmptyCashier.customers addObject:@(numberOfItems)];
                        }
                        else {
                            NSArray* sortedCashiers = [cashiers sortedArrayUsingComparator:^NSComparisonResult(Cashier* obj1, Cashier* obj2) {
                                if ([obj1.customers.lastObject integerValue] > [obj2.customers.lastObject integerValue]) {
                                    return NSOrderedAscending;
                                }
                                else {
                                    return NSOrderedDescending;
                                }
                            }];
                            Cashier* cashierWithSmallestLastCustomer = sortedCashiers.firstObject;
                            [cashierWithSmallestLastCustomer.customers addObject:@(numberOfItems)];
                        }
                    }
                    else {
                        return @{@"success":@NO,@"error":NSLocalizedString(@"Customers should either be type 'A' or 'B.'", nil)};
                    }
                }
            }
            
            //are all cashiers free AND all customers processed?
            NSArray* busyCashiers = [cashiers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customers.@count > 0"]];
            if (busyCashiers.count == 0 && currentTime >= latestArrivalTime) {
                return @{@"success":@YES,@"minutes":@(currentTime)};
            }
            
            currentTime++;
        }
    }
}

- (void) showErrorMessage:(NSString*)message {
    NSLog(@"Error: %@", message);
}

- (void) showOutputMessage:(NSInteger)minutes {
    NSLog(@"Finished at: t=%d minutes", minutes);
}

@end
