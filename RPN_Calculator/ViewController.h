//
//  ViewController.h
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/8/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (id)initWithCoder:(NSCoder *)coder;

// UI References
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *stackDisplay;

@end

