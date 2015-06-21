//
//  GraphingViewController.m
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/11/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphingViewController.h"

@implementation GraphingViewController

static const double PAN_SPEED_SCALE_FACTOR = 0.04f;
static const double PINCH_SPEED_SCALE_FACTOR = 1.0f;

// Properties

- (void)viewDidLoad {
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
    
    // Add gesture recognisers
    UIPanGestureRecognizer *panGestureRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:panGestureRecogniser];
    
    UIPinchGestureRecognizer *pinchGestureRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchGestureRecogniser];
    
    UITapGestureRecognizer *tripleTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTripleTaps:)];
    tripleTapGestureRecogniser.numberOfTapsRequired = 3;
    tripleTapGestureRecogniser.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tripleTapGestureRecogniser];
}


- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    CGVector panAmount = CGVectorMake(translation.x * PAN_SPEED_SCALE_FACTOR * -1.0f,
                                      translation.y * PAN_SPEED_SCALE_FACTOR);
    [self.graphingViewRef panByAmount:panAmount];
    
    [sender setTranslation:CGPointZero inView:self.view];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)sender {
    CGFloat scale = [sender scale] * PINCH_SPEED_SCALE_FACTOR;
    [self.graphingViewRef scaleByAmount:scale];
    [sender setScale:1.0f];
}

- (void)handleTripleTaps:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    [self.graphingViewRef moveOriginToScreenSpacePoint:location];
    NSLog(@"%g, %g", location.x, location.y);
}


// Implement interface GraphingViewDataSourceDelegate
- (double)getFunctionValueAtVariableValue:(double)x withSender:(GraphingView *)sender {
    return [self.savedExpressionEvaluatorDelegate getValueOfExpression:self.savedExpression atValue:x];
}

- (void)graphExpression:(id)expression withEvaluator:(id <ExpressionEvaluatorDelegate>)evaluatorDelegate {
    self.savedExpression = [expression copy];
    self.savedExpressionEvaluatorDelegate = evaluatorDelegate;
    
    [self.graphingViewRef setNeedsDisplay];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end