//
//  GraphingView.h
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/11/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#ifndef RPN_Calculator_GraphingView_h
#define RPN_Calculator_GraphingView_h

#import <UIKit/UIKit.h>

@class GraphingView;

@protocol GraphingViewDataSourceDelegate <NSObject>
@required
- (double)getFunctionValueAtVariableValue:(double)x withSender:(GraphingView *)sender;
@end

@interface GraphingView : UIView

- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)initWithFrame:(CGRect)frame;
- (id)customInit;

- (void)drawRect:(CGRect)rect;

@property (nonatomic) id<GraphingViewDataSourceDelegate> dataSourceDelegate;

@end

#endif
