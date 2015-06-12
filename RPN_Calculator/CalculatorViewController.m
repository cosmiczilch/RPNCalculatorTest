//
//  ViewController.m
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/8/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#import "CalculatorViewController.h"
#import "RPNCalculator.h"

@interface CalculatorViewController ()

// Whether the user has begun entering input
@property (nonatomic) BOOL currentlyEnteringInput;

// An instance of the calculator model
@property (nonatomic) RPNCalculator *rpnCalculator;

// Dictionary of variable values keyed by variable names
@property (nonatomic) NSMutableDictionary *variableKVPs;

- (void) updateVariablesUsedDisplayAndStackDisplayWithString:(NSString *)stringToAppend;

@end


@implementation CalculatorViewController

// Overridden Constructors:
- (id)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        // Custom initialization
        if (!self.rpnCalculator) {
            self.rpnCalculator = [[RPNCalculator alloc] init];
        }
        if (!self.variableKVPs) {
            self.variableKVPs = [[NSMutableDictionary alloc] init];
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
    else if ([@"π"     isEqualToString:sender.currentTitle])  { operator = OPERATOR_PI; }
    
    // Pass on the appropriate operator to the rpn calculator
    double result = [self.rpnCalculator ProcessOperator:operator withVariables:[self.variableKVPs copy]];
    [self updateVariablesUsedDisplayAndStackDisplayWithString:sender.currentTitle];
    
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
        if ([self.display.text isEqualToString:@"x"] ||
            [self.display.text isEqualToString:@"y"] ||
            [self.display.text isEqualToString:@"z"]) {
            
            // Its a variable
            [self.rpnCalculator PushVariable:self.display.text];
        } else {
            
            // Its a regular number
            [self.rpnCalculator PushOperand:[self.display.text doubleValue]];
            
        }
        [self updateVariablesUsedDisplayAndStackDisplayWithString:self.display.text];
    }
}

- (IBAction)ClearButtonPressed {
    [self.rpnCalculator Reset];
    [self clearStackDisplay];
    
    self.currentlyEnteringInput = false;
    self.display.text = @"0.0";
}

- (IBAction)VariableButtonPressed:(UIButton *)sender {
    
    // Do not allow variables in the middle of numbers, for instance 23x
    if (!self.currentlyEnteringInput) {
        
        unichar variableNameChar = [sender.currentTitle characterAtIndex:0];
        if (variableNameChar == 'x' || variableNameChar == 'y' || variableNameChar == 'z') {
            
            NSString *variableName = [NSString stringWithCharacters:&variableNameChar length:1];
            self.display.text = variableName;
            
            // Simulate enter pressed to send the variable to the calculator
            self.currentlyEnteringInput = true;
            [self EnterPressed];
            
        } else {
            NSLog(@"Unrecognized variable name");
        }
    }
}

- (IBAction)CaptureX:(UIButton *)sender {
    [self captureCurrentResultAsVariable:@"x"];
}

- (IBAction)CaptureY:(UIButton *)sender {
    [self captureCurrentResultAsVariable:@"y"];
}

- (IBAction)CaptureZ:(UIButton *)sender {
    [self captureCurrentResultAsVariable:@"z"];
}

- (IBAction)UndoPressed:(UIButton *)sender {
    if (self.currentlyEnteringInput) {
        NSString *newInput = self.display.text;
        if ([newInput length] > 0) {
            newInput = [newInput substringToIndex:[newInput length] - 1];
        }
        self.display.text = newInput;
        if ([self.display.text length] == 0) {
            self.currentlyEnteringInput = false;
        }
        
    } else {
        [self.rpnCalculator UndoLastOperation];
        [self updateVariablesUsedDisplayAndStackDisplayWithString:@""];
    }
}

- (IBAction)GraphButtonPressed:(UIButton *)sender {
    if (self.splitViewController) {
        // We're running in a split view container, grab the graphing view controller
        id graphingViewController = [self.splitViewController.childViewControllers lastObject];
        if ([graphingViewController isKindOfClass:[GraphingViewController class]]) {
            [self configureGraphingViewController:graphingViewController];
        }
        
    } else {
        // Segue to a new graphing view controller
        [self performSegueWithIdentifier:@"ShowGraphSegue" sender:self];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowGraphSegue"]) {
        NSLog(@"Prepare for segue");
        if ([segue.destinationViewController isKindOfClass:[GraphingViewController class]]) {
            [self configureGraphingViewController:segue.destinationViewController];
        }
    }
}

- (void)configureGraphingViewController:(GraphingViewController *)controller {
    [controller graphExpression:[self.rpnCalculator currentProgram] withEvaluator:self];
}

// Implement interface ExpressionEvaluatorDelegate
- (double) getValueOfExpression:(id)expression atValue:(double)value {
    NSMutableDictionary *variableDictionary = [[NSMutableDictionary alloc] init];
    [variableDictionary setValue:[NSNumber numberWithDouble:value] forKey:@"x"];
    return [RPNCalculator runProgram:expression withVariables:variableDictionary];
}

// Private Helpers

- (void) updateVariablesUsedDisplayAndStackDisplayWithString:(NSString *)stringToAppend {
    
    // Show the infix notation of the currently entered expression
    self.stackDisplay.text = [RPNCalculator getDescriptionOfProgram:self.rpnCalculator.currentProgram];
    
    // Update variables used:
    NSString *result = @"";
    NSSet *variablesUsed = [RPNCalculator variablesUsedInProgram:self.rpnCalculator.currentProgram];
    if (variablesUsed) {
        for (id variable in variablesUsed) {
            if ([variable isKindOfClass:[NSString class]]) {
                NSString *variableName = (NSString *)variable;
                result = [NSString stringWithFormat:@"%@%@ = %g, ", result, variableName, [self getValueForVariableByKey:variableName]];
            }
        }
    }
    self.variablesUsedDisplay.text = result;
}

- (void) clearStackDisplay {
    self.stackDisplay.text = @"";
    self.variablesUsedDisplay.text = @"";
}

- (void) captureCurrentResultAsVariable:(NSString*)variableName {
    double currentResult = [self.display.text doubleValue];
    [self addVariableValue:currentResult ForKey:variableName];
}

- (void) addVariableValue:(double)value ForKey:(NSString *)key {
    id valueId = [NSNumber numberWithDouble:value];
    [self.variableKVPs setValue:valueId forKey:key];
}

- (double) getValueForVariableByKey:(NSString *)key {
    id value = [self.variableKVPs valueForKey:key];
    if (value) {
        return [value doubleValue];
    }
    return 0.0;
}

@end
