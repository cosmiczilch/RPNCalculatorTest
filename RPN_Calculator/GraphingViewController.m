//
//  GraphingViewController.m
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/11/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphingViewController.h"

@interface GraphingViewController()
@end

@implementation GraphingViewController

// Properties

- (void) viewDidLoad {
    if ([self.view isKindOfClass:[GraphingView class]]) {
        self.graphingViewRef = (GraphingView *)self.view;
        self.graphingViewRef.dataSourceDelegate = self;
    }
    
    // Add split display controller's master view button to the toolbar
    if (self.splitViewController) {
        // Hide our back button, and use the split view controller's instead
        self.backButton.hidden = true;
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        [buttons addObject:self.splitViewController.displayModeButtonItem];
        [self.toolbar setItems:[buttons copy]];
    }
}

// Implement interface GraphingViewDataSourceDelegate
- (double) getFunctionValueAtVariableValue:(double)x withSender:(GraphingView *)sender {
    return [self.savedExpressionEvaluatorDelegate getValueOfExpression:self.savedExpression atValue:x];
}

- (void) graphExpression:(id)expression withEvaluator:(id <ExpressionEvaluatorDelegate>)evaluatorDelegate {
    self.savedExpression = [expression copy];
    self.savedExpressionEvaluatorDelegate = evaluatorDelegate;
    
    [self.graphingViewRef setNeedsDisplay];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end