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
@property (assign, nonatomic) NSInteger latestArrivalTime;
@property (assign, nonatomic) BOOL traineeIsStartingNewItem;

@end

@implementation ViewController

#define kTypeA @"A"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    self.mainTextView.text = @"2\nA 1 5\nB 2 1\nA 3 5\nB 5 3\nA 8 2";
}

- (void) keyboardWillShow:(NSNotification*)sender {
    NSDictionary* userInfo = sender.userInfo;
    CGRect keyboardRect = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    self.goButtonHeightFromBottomConstraint.constant = CGRectGetHeight(keyboardRect) + 10;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}
- (IBAction)goButtonTapped:(id)sender {
    self.latestArrivalTime = 0;
    self.traineeIsStartingNewItem = NO;
    
    NSMutableArray* rows = [[self.mainTextView.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    if (rows.count < 2) {
        [self showErrorMessage:NSLocalizedString(@"Please enter at least 2 rows.", nil)];
        return;
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
        
        while (YES) {
            //PROCESSING EXISTING CUSTOMERS
            for (Cashier* cashier in cashiers) {
                if (cashier.customers.count > 0) {
                    //DEAL WITH TRAINING CASHIER
                    if ([cashier isEqual:cashiers.lastObject]) {
                        if (self.traineeIsStartingNewItem) {
                            self.traineeIsStartingNewItem = NO;
                            //trainee has finally finished the item! can do the below logic
                        }
                        else {
                            self.traineeIsStartingNewItem = YES;
                            break; //starting a new item -- can't do the below
                        }
                    }
                    
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
            
            //ADDING CUSTOMERS
            for (NSString* customerRow in rows) {
                NSArray* customerData = [customerRow componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (customerData.count != 3) {
                    [self showErrorMessage:NSLocalizedString(@"Each row should have exactly 3 items.", nil)];
                    return;
                }
                NSInteger arrivalTime = [[customerData objectAtIndex:1] integerValue];
                if (arrivalTime > self.latestArrivalTime) {
                    self.latestArrivalTime = arrivalTime;
                }
                
                if (arrivalTime == currentTime) {
                    NSString* type = customerData.firstObject;
                    NSInteger numberOfItems = [customerData.lastObject integerValue];
                    if ([type isEqualToString:kTypeA]) {
                        NSArray* sortedCashiers = [cashiers sortedArrayUsingComparator:^NSComparisonResult(Cashier* obj1, Cashier* obj2) {
                            if (obj1.customers.count > obj2.customers.count) { //thanks http://stackoverflow.com/a/17498269/2284713
                                return NSOrderedAscending;
                            }
                            else {
                                return NSOrderedDescending;
                            }
                        }];
                        Cashier* cashierWithLeastCustomers = sortedCashiers.firstObject;
                        [cashierWithLeastCustomers.customers addObject:@(numberOfItems)];
                    }
                    else { //typeB
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
                }
            }
            
            //are all cashiers free AND all customers processed?
            NSArray* busyCashiers = [cashiers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customers.@count > 0"]];
            if (busyCashiers.count == 0 && currentTime >= self.latestArrivalTime) {
                [self showOutputMessage:currentTime];
                return;
            }
            
            currentTime++;
        }
    }
}

- (void) showErrorMessage:(NSString*)message {
    NSLog(@"error is %@", message);
}

- (void) showOutputMessage:(NSInteger)minutes {
    NSLog(@"Finished at: t=%d minutes", minutes);
}

@end
