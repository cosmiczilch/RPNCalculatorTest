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

// Whether the user has begun entering input
@property (nonatomic) BOOL currentlyEnteringInput;

// An instance of the calculator model
@property (nonatomic) RPNCalculator *rpnCalculator;

// A string that holds every operand and operator that has been sent to the calculator, seperated by white spaces
@property (nonatomic) NSString *currentInputStringComplete;

@property (nonatomic) NSMutableDictionary *variableKVPs;

- (void) updateStackDisplayWithString:(NSString *)stringToAppend;

@end


@implementation ViewController

// Overridden Constructor:
- (id)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        // Custom initialization
        if (!self.rpnCalculator) {
            self.rpnCalculator = [[RPNCalculator alloc] init];
        }
        if (!self.currentInputStringComplete) {
            self.currentInputStringComplete = @"";
        }
    }
    
    return self;
}

// UI Event Handlers

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
    
    // Pass on the appropriate operator to the rpn calculator
    double result = [self.rpnCalculator ProcessOperator:operator];
    [self updateStackDisplayWithString:sender.currentTitle];
    
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
        
        // Pass on the appropriate operand to the rpn calculator
        [self.rpnCalculator PushOperand:[self.display.text doubleValue]];
        [self updateStackDisplayWithString:self.display.text];
    }
}

- (IBAction)ClearButtonPressed {
    [self.rpnCalculator Reset];
    [self clearStackDisplay];
    
    self.currentlyEnteringInput = false;
    self.display.text = @"0.0";
}

- (IBAction)VariableButtonPressed:(UIButton *)sender {
}

- (IBAction)CaptureX:(UIButton *)sender {
}

- (IBAction)CaptureY:(UIButton *)sender {
}

- (IBAction)CaptureZ:(UIButton *)sender {
}

// Private Helpers

- (void) updateStackDisplayWithString:(NSString *)stringToAppend {
    
    self.currentInputStringComplete = [self.currentInputStringComplete stringByAppendingString:@" "];
    self.currentInputStringComplete = [self.currentInputStringComplete stringByAppendingString:stringToAppend];
    self.stackDisplay.text = self.currentInputStringComplete;
}

- (void) clearStackDisplay {
    self.currentInputStringComplete = @"";
    self.stackDisplay.text = self.currentInputStringComplete;
}

@end
