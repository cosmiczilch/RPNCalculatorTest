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
- (void)viewDidLoad;

// UI References
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *stackDisplay;
@property (weak, nonatomic) IBOutlet UILabel *variablesUsedDisplay;

// Reference to the graphing view controller used to graph the expression
@property (weak, nonatomic) GraphingViewController *graphingViewControllerRef;

// Implement interface ExpressionEvaluatorDelegate
- (double) getValueOfExpression:(id)expression atValue:(double)value;

@end

