//
//  ViewController.m
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/8/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#import "ViewController.h"
#import "RPNCalculator.h"

@interface ViewController ()

@property (nonatomic) BOOL currentlyEnteringInput;
@property (nonatomic) RPNCalculator *rpnCalculator;

@end


@implementation ViewController

@synthesize display = _display;
@synthesize currentlyEnteringInput = _currentlyEnteringInput;
@synthesize rpnCalculator = _rpnCalculator;

- (RPNCalculator *) rpnCalculator {
    if (!_rpnCalculator) {
        _rpnCalculator = [[RPNCalculator alloc] init];
    }
    return _rpnCalculator;
}

- (IBAction)OperatorPressed:(UIButton *)sender {
    
    if (self.currentlyEnteringInput) {
        [self EnterPressed];
    }
    
    OPERATOR_t operator = OPERATOR_INVALID;
    if      ([@"+"      isEqualToString:sender.currentTitle])  { operator = OPERATOR_PLUS; }
    else if ([@"-"      isEqualToString:sender.currentTitle])  { operator = OPERATOR_MINUS; }
    else if ([@"x"      isEqualToString:sender.currentTitle])  { operator = OPERATOR_MULTIPLY; }
    else if ([@"/"      isEqualToString:sender.currentTitle])  { operator = OPERATOR_DIVIDE; }
    else if ([@"sin"    isEqualToString:sender.currentTitle])  { operator = OPERATOR_SIN; }
    else if ([@"cos"    isEqualToString:sender.currentTitle])  { operator = OPERATOR_COS; }
    else if ([@"sqrt"   isEqualToString:sender.currentTitle])  { operator = OPERATOR_SQRT; }
    else if ([@"pi"     isEqualToString:sender.currentTitle])  { operator = OPERATOR_PI; }
    
    double result = [self.rpnCalculator ProcessOperator:operator];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)DigitPressed:(UIButton *)sender {
    
    if (!self.currentlyEnteringInput) {
        self.currentlyEnteringInput = true;
        self.display.text = sender.currentTitle;
        
    } else {
        
        if ([@"." isEqualToString:sender.currentTitle]) {
            if ([self.display.text containsString:@"."]) {
                // Ignore multiple decimal points in floating point numbers
                return;
            }
        }
        self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
    }
}

- (IBAction)EnterPressed {

    if (self.currentlyEnteringInput) {
        self.currentlyEnteringInput = false;
        [self.rpnCalculator PushOperand:[self.display.text doubleValue]];
    }
}

- (IBAction)ClearButtonPressed {
    self.currentlyEnteringInput = false;
    self.display.text = @"0.0";
    [self.rpnCalculator Reset];
}

@end
