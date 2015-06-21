//
//  GraphingViewController.h
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/11/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#ifndef RPN_Calculator_GraphingViewController_h
#define RPN_Calculator_GraphingViewController_h

#import <UIKit/UIKit.h>

#import "RPNCalculator.h"
#import "GraphingView.h"

@protocol ExpressionEvaluatorDelegate <NSObject>
- (double) getValueOfExpression:(id)expression atValue:(double)value;
@end

@interface GraphingViewController : UIViewController <GraphingViewDataSourceDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic) GraphingView *graphingViewRef;

@property (weak, nonatomic) id<ExpressionEvaluatorDelegate> savedExpressionEvaluatorDelegate;
@property (strong, nonatomic) id savedExpression;

- (void)graphExpression:(id)expression withEvaluator:(id <ExpressionEvaluatorDelegate>)evaluatorDelegate;

// Implement interface GraphingViewDataSourceDelegate
- (double)getFunctionValueAtVariableValue:(double)x withSender:(GraphingView *)sender;

@end

#endif
