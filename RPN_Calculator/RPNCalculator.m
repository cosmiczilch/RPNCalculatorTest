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

@property (nonatomic) NSMutableArray *programStack;

@end

@implementation RPNCalculator

// The current expression being evaluated
@synthesize programStack = _programStack;

- (NSMutableArray *) programStack {
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

// Helpers:

// Public Methods an Properties:

- (id) currentProgram {
    id immutableCopy = [self.programStack copy];
    return immutableCopy;
}

- (void) PushOperand:(double)operand {
    
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void) PushVariable:(NSString *)variableName {
    
    [self.programStack addObject:[variableName copy]];
}

- (double) ProcessOperator:(OPERATOR_t)operator withVariables:(NSDictionary *)variableValues {
    
    [self.programStack addObject:[NSValue value:&operator withObjCType:@encode(OPERATOR_t)]];
   
    return [RPNCalculator runProgram:[self currentProgram] withVariables:variableValues];
}

- (void) Reset {
    [self.programStack removeAllObjects];
}

- (void) UndoLastOperation {
    if ([self.programStack count] > 0) {
        [self.programStack removeLastObject];
    }
}

// Static methods

+ (double) evaluateProgramStackRecursive:(NSMutableArray *)programStack withVariables:(NSDictionary *)variableValues {
    double result = 0.0;
    double operand1, operand2;
    
    // Take the last token of the expression off the stack
    id topOfStack = [programStack lastObject];
    if (topOfStack) {
        [programStack removeLastObject];
    }
    
    if ([topOfStack isKindOfClass:[NSString class]]) {
        // If it is a variable, return the value of the variable from the dictionary
        NSString *variableName = (NSString *)topOfStack;
        result = [[variableValues valueForKey:variableName] doubleValue];
        
    }
    else if ([topOfStack isKindOfClass:[NSNumber class]]) {
        // If its a constant, return the constant
        result = [topOfStack doubleValue];
        
    } else if ([topOfStack isKindOfClass:[NSValue class]]) {
        // If its an operator, recursively evaluate the expression
        
        OPERATOR_t operator;
        [topOfStack getValue:&operator];
    
        switch (operator) {
            case OPERATOR_PLUS:     result = [self evaluateProgramStackRecursive:programStack withVariables:variableValues] + [self evaluateProgramStackRecursive:programStack withVariables:variableValues]; break;
            case OPERATOR_MINUS:    result = ([self evaluateProgramStackRecursive:programStack withVariables:variableValues] - [self evaluateProgramStackRecursive:programStack withVariables:variableValues]) * -1.0; break;
            case OPERATOR_MULTIPLY: result = [self evaluateProgramStackRecursive:programStack withVariables:variableValues] * [self evaluateProgramStackRecursive:programStack withVariables:variableValues]; break;
            case OPERATOR_DIVIDE:
                operand2 = [self evaluateProgramStackRecursive:programStack withVariables:variableValues];
                operand1 = [self evaluateProgramStackRecursive:programStack withVariables:variableValues];
                if (operand2 != 0.0f) {
                    result = operand1 / operand2;
                }
            case OPERATOR_SIN:      result = sin([self evaluateProgramStackRecursive:programStack withVariables:variableValues]); break;
            case OPERATOR_COS:      result = cos([self evaluateProgramStackRecursive:programStack withVariables:variableValues]); break;
            case OPERATOR_SQRT:     result = sqrt([self evaluateProgramStackRecursive:programStack withVariables:variableValues]); break;
            case OPERATOR_PI:       result = PI;
            default: break;
        }
    }
    
    return result;
}

+ (double) runProgram:(id)program withVariables:(NSDictionary *)variableValues {
    double result = 0.0;
    
    NSMutableArray *programStack = nil;
    if ([program isKindOfClass:[NSArray class]]) {
        programStack = [program mutableCopy];
        if (programStack) {
            result = [self evaluateProgramStackRecursive:programStack withVariables:variableValues];
        }
    }
    
    return  result;
}

+ (NSString *) getInfixExpressionFromPostfixExpression:(NSMutableArray *)postfixExpression {
    id topOfStack = [postfixExpression lastObject];
    if (topOfStack) {
        [postfixExpression removeLastObject];
    }
    
    if (!topOfStack) {
        // Nothing to do
        return @"";
        
    } else if ([topOfStack isKindOfClass:[NSNumber class]]) {
        // Its a number, return it
        return [topOfStack stringValue];
        
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        // Its a variable, return it
        return (NSString *)topOfStack;
        
    } else if ([topOfStack isKindOfClass:[NSValue class]]) {
        // Its an operator, recursively construct the infix expression
        
        OPERATOR_t operator;
        [topOfStack getValue:&operator];
        
        switch (operator) {
            case OPERATOR_PLUS:
                return [NSString stringWithFormat:@"(%@ + %@)", [self getInfixExpressionFromPostfixExpression:postfixExpression], [self getInfixExpressionFromPostfixExpression:postfixExpression]];
                break;
                
            case OPERATOR_MINUS:
                return [NSString stringWithFormat:@"(%@ - %@)", [self getInfixExpressionFromPostfixExpression:postfixExpression], [self getInfixExpressionFromPostfixExpression:postfixExpression]];
                break;
                
            case OPERATOR_MULTIPLY:
                return [NSString stringWithFormat:@"(%@ * %@)", [self getInfixExpressionFromPostfixExpression:postfixExpression], [self getInfixExpressionFromPostfixExpression:postfixExpression]];
                break;
                
            case OPERATOR_DIVIDE:
                return [NSString stringWithFormat:@"(%@ / %@)", [self getInfixExpressionFromPostfixExpression:postfixExpression], [self getInfixExpressionFromPostfixExpression:postfixExpression]];
                break;
                
            case OPERATOR_SIN:
                return [NSString stringWithFormat:@"sin(%@)", [self getInfixExpressionFromPostfixExpression:postfixExpression]];
                break;
                
            case OPERATOR_COS:
                return [NSString stringWithFormat:@"cos(%@)", [self getInfixExpressionFromPostfixExpression:postfixExpression]];
                break;
                
            case OPERATOR_SQRT:
                return [NSString stringWithFormat:@"sqrt(%@)", [self getInfixExpressionFromPostfixExpression:postfixExpression]];
                break;
                
            case OPERATOR_PI:
                return @"π";
                break;
                
                
            default:
                break;
        }
    }
    return @"";
}

+ (NSString *) getDescriptionOfProgram:(id)program {
    NSString *description = @"";
    if ([program isKindOfClass:[NSArray class]]) {
        NSMutableArray *programMutable = [program mutableCopy];
        while ([programMutable count] > 0) {
            description = [NSString stringWithFormat:@"%@%@, ", description, [self getInfixExpressionFromPostfixExpression:programMutable]];
        }
    }
    
    return  description;
}

+ (NSSet *) variablesUsedInProgram:(id)program {
    NSMutableSet *result = [[NSMutableSet alloc] init];
    
    if ([program isKindOfClass:[NSArray class]]) {
        for (id token in program) {
            if ([token isKindOfClass:[NSString class]]) {
                [result addObject:token];
            }
        }
    }
    
    // Return immutable copy:
    return [result copy];
}

@end

#endif
