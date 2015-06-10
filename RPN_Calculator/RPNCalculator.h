//
//  RPNCalculator.m
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/8/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PI 3.141593

// Supported Operations
typedef enum {
    OPERATOR_PLUS,
    OPERATOR_MINUS,
    OPERATOR_MULTIPLY,
    OPERATOR_DIVIDE,
    OPERATOR_SIN,
    OPERATOR_COS,
    OPERATOR_SQRT,
    OPERATOR_PI,
    OPERATOR_INVALID,
    
} OPERATOR_t;

@interface RPNCalculator : NSObject

- (void)    PushOperand:(double)operand;
- (double)  ProcessOperator:(OPERATOR_t)operator;
- (void)    Reset;

@property (readonly) id currentProgram;

+ (double) runProgram:(id)program;
+ (NSString *) getDescriptionOfProgram:(id)program;

@end

