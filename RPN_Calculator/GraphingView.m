//
//  GraphingView.m
//  RPN_Calculator
//
//  Created by Avinash Krishnan on 6/11/15.
//  Copyright (c) 2015 Avinash Krishnan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GraphingView.h"

struct CartesianBounds {
    CGFloat xMin;
    CGFloat xMax;
    CGFloat yMin;
    CGFloat yMax;
};
typedef struct CartesianBounds CartesianBounds;
CartesianBounds CartesianBoundsMake(CGFloat xMin, CGFloat xMax, CGFloat yMin, CGFloat yMax) {
    CartesianBounds cartesianBounds;
    cartesianBounds.xMin = xMin;
    cartesianBounds.xMax = xMax;
    cartesianBounds.yMin = yMin;
    cartesianBounds.yMax = yMax;
    return cartesianBounds;
}


@interface GraphingView()

@property (readonly) CGVector screenDimensionsInPoints;
@property (nonatomic) CartesianBounds currentCartesianBounds;

@end

@implementation GraphingView

// Constructors

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)customInit {
    // Sane defaults:
    self.currentCartesianBounds = CartesianBoundsMake(-10.0f, 10.0f, -10.0f, 10.0f);
    
    // Restore saved preferences if any
    [self restoreUserDefaults];
    
    return self;
}


// Properties

- (CGVector)screenDimensionsInPoints {
    return CGVectorMake(self.frame.size.width, self.frame.size.height);
}


// Coordinate system helpers

- (CGPoint)getScreenSpacePointForCartesianPoint:(CGPoint)cartesianPoint {
    CGPoint screenspacePoint;
    screenspacePoint.x = (cartesianPoint.x - self.currentCartesianBounds.xMin) / (self.currentCartesianBounds.xMax - self.currentCartesianBounds.xMin) * self.screenDimensionsInPoints.dx;
    screenspacePoint.y = (self.currentCartesianBounds.yMax - cartesianPoint.y) / (self.currentCartesianBounds.yMax - self.currentCartesianBounds.yMin) * self.screenDimensionsInPoints.dy;
    
    return screenspacePoint;
}

- (CGPoint)getCartesianPointForScreenSpacePoint:(CGPoint)screenspacePoint {
    CGPoint cartesianPoint;
    cartesianPoint.x =  (screenspacePoint.x * (self.currentCartesianBounds.xMax - self.currentCartesianBounds.xMin) / self.screenDimensionsInPoints.dx) + self.currentCartesianBounds.xMin;
    cartesianPoint.y = ((screenspacePoint.y * (self.currentCartesianBounds.yMax - self.currentCartesianBounds.yMin) / self.screenDimensionsInPoints.dy) - self.currentCartesianBounds.yMax) * -1.0f;
    
    return cartesianPoint;
}

// Drawing Helpers

- (void)drawLinefromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 withThickness:(CGFloat)thickness andColor:(CGFloat[4])color inContext:(CGContextRef)context {
    
    // Convert given points from cartesian to screen space
    CGPoint point1InScreenspace = [self getScreenSpacePointForCartesianPoint:point1];
    CGPoint point2InScreenspace = [self getScreenSpacePointForCartesianPoint:point2];
    
    UIGraphicsPushContext(context);
    
    // Set line drawing properties
    CGContextSetLineWidth(context, thickness);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorspace, color);
    CGContextSetStrokeColorWithColor(context, colorRef);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, point1InScreenspace.x, point1InScreenspace.y);
    CGContextAddLineToPoint(context, point2InScreenspace.x, point2InScreenspace.y);
    CGContextClosePath(context);
    
    // Release
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(colorRef);
    
    UIGraphicsPopContext();  
}

- (void)drawAxesWithContext:(CGContextRef)context {
    CGFloat color[] = {1.0f, 1.0f, 1.0f, 1.0f};
    
    // Draw x axis
    CGPoint start = CGPointMake(self.currentCartesianBounds.xMin, 0.0f);
    CGPoint end = CGPointMake(self.currentCartesianBounds.xMax, 0.0f);
    [self drawLinefromPoint:start toPoint:end withThickness:2.0f andColor:color inContext:context];
    
    // Draw y axis
    start = CGPointMake(0.0f, self.currentCartesianBounds.yMin);
    end = CGPointMake(0.0f, self.currentCartesianBounds.yMax);
    [self drawLinefromPoint:start toPoint:end withThickness:2.0f andColor:color inContext:context];
}

- (void) plotGraphWithContext:(CGContextRef)context {
    if (!self.dataSourceDelegate) {
        return;
    }
    
    CGFloat color[] = {1.0f, 1.0f, 1.0f, 1.0f};
    
    CGFloat x = self.currentCartesianBounds.xMin;
    double fx = [self.dataSourceDelegate getFunctionValueAtVariableValue:x withSender:self];
    CGPoint point1 = CGPointMake(x, fx);
    CGPoint point2;
    CGPoint screenspacePoint;
    
    CGFloat numPixelsAlongX = self.screenDimensionsInPoints.dx;
    for (int xPixel = 0; xPixel < numPixelsAlongX; ++xPixel) {
        
        screenspacePoint = CGPointMake(xPixel, 0.0f);
        x = [self getCartesianPointForScreenSpacePoint:screenspacePoint].x;
        fx = [self.dataSourceDelegate getFunctionValueAtVariableValue:x withSender:self];
        point2 = CGPointMake(x, fx);
        
        [self drawLinefromPoint:point1 toPoint:point2 withThickness:2.0f andColor:color inContext:context];
        point1 = point2;
    }
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawAxesWithContext:context];
    [self plotGraphWithContext:context];
}

- (void)panByAmount:(CGVector)amount {
    self.currentCartesianBounds = CartesianBoundsMake(
                                                      self.currentCartesianBounds.xMin + amount.dx,
                                                      self.currentCartesianBounds.xMax + amount.dx,
                                                      self.currentCartesianBounds.yMin + amount.dy,
                                                      self.currentCartesianBounds.yMax + amount.dy);
    [self setNeedsDisplay];
    [self saveUserDefaults];
}

- (void)scaleByAmount:(CGFloat)amount {
    if (amount == 0.0f) {
        return;
    }
    self.currentCartesianBounds = CartesianBoundsMake(
                                                      self.currentCartesianBounds.xMin / amount,
                                                      self.currentCartesianBounds.xMax / amount,
                                                      self.currentCartesianBounds.yMin / amount,
                                                      self.currentCartesianBounds.yMax / amount);
    [self setNeedsDisplay];
    [self saveUserDefaults];
}

- (void)moveOriginToScreenSpacePoint:(CGPoint)point {
    CGPoint newOriginInCartesianSpace = [self getCartesianPointForScreenSpacePoint:point];
    CGVector panAmount = CGVectorMake(-newOriginInCartesianSpace.x, -newOriginInCartesianSpace.y);
    
    [self panByAmount:panAmount];
    [self saveUserDefaults];
}

- (void)saveUserDefaults {
    NSUserDefaults *blob = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *origin = [[NSMutableDictionary alloc] init];
    [origin setObject:[NSNumber numberWithDouble:self.currentCartesianBounds.xMin] forKey:@"xMin"];
    [origin setObject:[NSNumber numberWithDouble:self.currentCartesianBounds.xMax] forKey:@"xMax"];
    [origin setObject:[NSNumber numberWithDouble:self.currentCartesianBounds.yMin] forKey:@"yMin"];
    [origin setObject:[NSNumber numberWithDouble:self.currentCartesianBounds.yMax] forKey:@"yMax"];
    
    [blob setObject:[origin copy] forKey:@"savedOrigin"];
    
    [blob synchronize];
}

- (void)restoreUserDefaults {
    NSUserDefaults *blob = [NSUserDefaults standardUserDefaults];
    NSDictionary *origin = [blob objectForKey:@"savedOrigin"];
    if (origin) {
        self.currentCartesianBounds = CartesianBoundsMake(
                                                          [[origin objectForKey:@"xMin"] doubleValue],
                                                          [[origin objectForKey:@"xMax"] doubleValue],
                                                          [[origin objectForKey:@"yMin"] doubleValue],
                                                          [[origin objectForKey:@"yMax"] doubleValue]);
    }
}


@end

