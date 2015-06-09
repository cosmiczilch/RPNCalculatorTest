//
//  RPNCalculator.h
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/8/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#ifndef RPN_Calculator_RPNCalculator_h
#define RPN_Calculator_RPNCalculator_h

#import "RPNCalculator.h"

@interface RPNCalculator()

@property (nonatomic) NSMutableArray *operandsStack;

@end

@implementation RPNCalculator

@synthesize operandsStack = _operandsStack;

- (NSMutableArray *) operandsStack {
    if (!_operandsStack) {
        _operandsStack = [[NSMutableArray alloc] init];
    }
    return _operandsStack;
}

// Helpers:
- (double) popOperand {
    NSNumber *topOfStack = self.operandsStack.lastObject;
    if (topOfStack) {
        [self.operandsStack removeLastObject];
    }
    return [topOfStack doubleValue];
}

// Public Methods:
- (void) PushOperand:(double)operand {
    [self.operandsStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double) ProcessOperator:(OPERATOR_t)operator {
    double result = 0.0f;
    double operand1 = 0.0;
    double operand2 = 0.0;
    
    switch (operator) {
        case OPERATOR_PLUS:     result = [self popOperand] + [self popOperand]; break;
        case OPERATOR_MINUS:    result = ([self popOperand] - [self popOperand]) * -1.0; break;
        case OPERATOR_MULTIPLY: result = [self popOperand] * [self popOperand]; break;
        case OPERATOR_DIVIDE:
            operand2 = [self popOperand];
            operand1 = [self popOperand];
            if (operand2 != 0.0f) {
                result = operand1 / operand2;
            }
        case OPERATOR_SIN:      result = sin([self popOperand] * PI / 180.0f); break;
        case OPERATOR_COS:      result = cos([self popOperand] * PI / 180.0f); break;
        case OPERATOR_SQRT:     result = sqrt([self popOperand]); break;
        default: break;
    }
    
    [self.operandsStack addObject:[NSNumber numberWithDouble:result]];
    return result;
}

- (void) Reset {
}

@end

#endif
