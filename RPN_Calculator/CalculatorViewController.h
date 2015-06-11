//
//  ViewController.h
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/8/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GraphingViewController.h"

@interface CalculatorViewController : UIViewController <ExpressionEvaluatorDelegate>

- (id)initWithCoder:(NSCoder *)coder;

// UI References
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *stackDisplay;
@property (weak, nonatomic) IBOutlet UILabel *variablesUsedDisplay;

// Implement interface ExpressionEvaluatorDelegate
- (double) getValueOfExpression:(id)expression atValue:(double)value;

@end

