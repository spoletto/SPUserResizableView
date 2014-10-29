//
//  SPUserResizableView.m
//  SPUserResizableView
//
//  Created by Stephen Poletto on 12/10/11.
//

#import "SPUserResizableView.h"
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

static SPUserResizableViewAnchorPoint SPUserResizableViewNoResizeAnchorPoint = { 0.0, 0.0, 0.0, 0.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewUpperLeftAnchorPoint = { 1.0, 1.0, -1.0, 1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewMiddleLeftAnchorPoint = { 1.0, 0.0, 0.0, 1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewLowerLeftAnchorPoint = { 1.0, 0.0, 1.0, 1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewUpperMiddleAnchorPoint = { 0.0, 1.0, -1.0, 0.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewUpperRightAnchorPoint = { 0.0, 1.0, -1.0, -1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewMiddleRightAnchorPoint = { 0.0, 0.0, 0.0, -1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewLowerRightAnchorPoint = { 0.0, 0.0, 1.0, -1.0 };
static SPUserResizableViewAnchorPoint SPUserResizableViewLowerMiddleAnchorPoint = { 0.0, 0.0, 1.0, 0.0 };

@interface SPGripViewBorderView : UIView

@property (nonatomic) float resizableInset;
@property (nonatomic) float interactiveBorderSize;

@end

@implementation SPGripViewBorderView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // (1) Draw the bounding box.
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, [self interactiveBorderSize]/2, [self interactiveBorderSize]/2));
    CGContextStrokePath(context);
    
    // (2) Calculate the bounding boxes for each of the anchor points.
    CGRect upperLeft = CGRectMake(0.0, 0.0, [self interactiveBorderSize], [self interactiveBorderSize]);
    CGRect upperRight = CGRectMake(self.bounds.size.width - [self interactiveBorderSize], 0.0, [self interactiveBorderSize], [self interactiveBorderSize]);
    CGRect lowerRight = CGRectMake(self.bounds.size.width - [self interactiveBorderSize], self.bounds.size.height - [self interactiveBorderSize], [self interactiveBorderSize], [self interactiveBorderSize]);
    CGRect lowerLeft = CGRectMake(0.0, self.bounds.size.height - [self interactiveBorderSize], [self interactiveBorderSize], [self interactiveBorderSize]);
    CGRect upperMiddle = CGRectMake((self.bounds.size.width - [self interactiveBorderSize])/2, 0.0, [self interactiveBorderSize], [self interactiveBorderSize]);
    CGRect lowerMiddle = CGRectMake((self.bounds.size.width - [self interactiveBorderSize])/2, self.bounds.size.height - [self interactiveBorderSize], [self interactiveBorderSize], [self interactiveBorderSize]);
    CGRect middleLeft = CGRectMake(0.0, (self.bounds.size.height - [self interactiveBorderSize])/2, [self interactiveBorderSize], [self interactiveBorderSize]);
    CGRect middleRight = CGRectMake(self.bounds.size.width - [self interactiveBorderSize], (self.bounds.size.height - [self interactiveBorderSize])/2, [self interactiveBorderSize], [self interactiveBorderSize]);
    
    // (3) Create the gradient to paint the anchor points.
    CGFloat colors [] = {
        0.4, 0.8, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // (4) Set up the stroke for drawing the border of each of the anchor points.
    CGContextSetLineWidth(context, 1);
    CGContextSetShadow(context, CGSizeMake(0.5, 0.5), 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // (5) Fill each anchor point using the gradient, then stroke the border.
    CGRect allPoints[8] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight };
    for (NSInteger i = 0; i < 8; i++) {
        CGRect currPoint = allPoints[i];
        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, currPoint);
        CGContextClip(context);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMinY(currPoint));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMaxY(currPoint));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        CGContextStrokeEllipseInRect(context, CGRectInset(currPoint, 1, 1));
    }
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}

@end

@interface SPUserResizableView ()

- (void)translateUsingTouchLocation:(CGPoint)touchPoint;

/**
 *  Used for moving anchorPoint without loosing current position. Works with transform
 *  @author http://stackoverflow.com/a/5666430/740949
 *
 *  @param anchor CGPoint for new anchor
 *  @param view
 */
-(void)setAnchorPoint:(CGPoint)anchor;

/**
 *  Determines if we should not resize the by current settings.
 *
 *  @param touches
 *
 *  @return BOOL
 */
- (BOOL)isDisabledForTouches:(NSSet*)touches;

/**
 *  Checks if user did change the view
 *
 *  @return BOOL
 */
- (BOOL)willResize:(CGPoint)point;

/**
 *  Triggered when touches finished or canceled
 *
 *  @param touches
 */
- (void)touchesFinished:(NSSet *)touches;

@end

@implementation SPUserResizableView

@synthesize contentView, minWidth, minHeight, preventsPositionOutsideSuperview, delegate;


- (void)setupDefaultAttributes {
    
    // craete border view
    borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, [self resizableInset], [self resizableInset])];
    [borderView setHidden:YES];
    
    [self addSubview:borderView];
    
    // setup
    self.minWidth = kSPUserResizableViewDefaultMinWidth;
    self.minHeight = kSPUserResizableViewDefaultMinHeight;
    self.preventsPositionOutsideSuperview = YES;
    
    _disable                = NO;
    
    [self setResizableInset:kSPUserResizableViewGlobalInset];
    [self setInteractiveBorderSize:kSPUserResizableViewInteractiveBorderSize];
    
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

// we need to update also border view
- (void)setResizableInset:(float)resizableInset {
    _resizableInset     = resizableInset;
    [borderView setResizableInset:resizableInset];
    
    [self setFrame:[self frame]];
}

- (void)setInteractiveBorderSize:(float)interactiveBorderSize {
    _interactiveBorderSize  = interactiveBorderSize;
    [borderView setInteractiveBorderSize:interactiveBorderSize];
    
    [self setFrame:[self frame]];
}

- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    
    contentView.frame = CGRectInset(self.bounds, [self resizableInset] + [self interactiveBorderSize]/2, [self resizableInset] + [self interactiveBorderSize]/2);
    
    [self addSubview:contentView];
    
    // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
    [borderView removeFromSuperview];
    [self addSubview:borderView];
    [self setFrame:[self frame]];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    
    if (contentView) {
        contentView.frame = CGRectInset(self.bounds, [self resizableInset] + [self interactiveBorderSize]/2, [self resizableInset] + [self interactiveBorderSize]/2);
        borderView.frame = CGRectInset(self.bounds, [self resizableInset], [self resizableInset]);
        [borderView setNeedsDisplay];
    }
}

- (BOOL)isResizing {
    return (anchorPoint.adjustsH || anchorPoint.adjustsW || anchorPoint.adjustsX || anchorPoint.adjustsY);
}

- (BOOL)isDisabledForTouches:(NSSet*)touches {
    return ([self disable] || ([self disableOnMultiTouch] && [touches count] > 1));
}

- (BOOL)willResize:(CGPoint)point {
    // dermine if we will make resize
    return [self isResizing] && (point.x != touchStart.x && point.y != touchStart.y);
}

- (void)showEditingHandles {
    [borderView setHidden:NO];
}

- (void)hideEditingHandles {
    [borderView setHidden:YES];
}

#pragma mark - Resize

- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    if ([self disable]) {
        return;
    }
    
    NSLog(@"Touch point %@",NSStringFromCGPoint(touchPoint));
    // save current rotation and scales
    CGFloat scaleX      = [[self valueForKeyPath:@"layer.transform.scale.x"] floatValue];
    CGFloat scaleY      = [[self valueForKeyPath:@"layer.transform.scale.y"] floatValue];
    CGFloat rotation    = [[self valueForKeyPath:@"layer.transform.rotation"] floatValue];
    
    // update current anchor point to update frane with transform
    
    //NSLog(@"H %f, W %f, X %f, Y %f", anchorPoint.adjustsH, anchorPoint.adjustsW, anchorPoint.adjustsX, anchorPoint.adjustsY);
    
    
    NSLog(@"Rotation %f",RADIANS_TO_DEGREES(rotation));
    
    
    CGPoint point;
    
    if (anchorPoint.adjustsY != 0) {
        if (anchorPoint.adjustsW != 0 && anchorPoint.adjustsX == 0) {
            point   = CGPointMake(0, 1);
        } else {
            point = CGPointMake(1, 1);
        }
    } else if (anchorPoint.adjustsX != 0) {
        point   = CGPointMake(1, 0);
    } else {
        point   = CGPointMake(0, 0);
    }
    
    
    [self setAnchorPoint:point];
    
    // restore to normal cords
    [self setTransform:CGAffineTransformIdentity];
    
    // (1) Update the touch point if we're outside the superview.
    
    if (self.preventsPositionOutsideSuperview) {
        CGFloat border = [self resizableInset] + [self interactiveBorderSize]/2;
        if (touchPoint.x < border) {
            touchPoint.x = border;
        }
        if (touchPoint.x > self.superview.bounds.size.width - border) {
            touchPoint.x = self.superview.bounds.size.width - border;
        }
        if (touchPoint.y < border) {
            touchPoint.y = border;
        }
        if (touchPoint.y > self.superview.bounds.size.height - border) {
            touchPoint.y = self.superview.bounds.size.height - border;
        }
    }
    
    // (2) Calculate the deltas using the current anchor point.
    
    CGPoint start   = touchStart;
    CGPoint end     = touchPoint;
    
    float rotationDeg   = RADIANS_TO_DEGREES(rotation);
    
    if (rotationDeg > 45.0 && rotationDeg < 135.0) {
        
        start.x     = touchStart.y;
        start.y     = touchPoint.x;
        
        end.x     = touchPoint.y;
        end.y     = touchStart.x;
    } else if (-45.0 > rotationDeg && rotationDeg > -135.0) {
        start.x     = touchPoint.y;
        start.y     = touchStart.x;
        
        end.x     = touchStart.y;
        end.y     = touchPoint.x;
        //} else if (-135.0 > rotationDeg) {
        
    } else if (rotationDeg > 135.0 || -135.0 > rotationDeg) {
        start   = touchPoint;
        end     = touchStart;
    }
    
    
    
    CGFloat deltaW = anchorPoint.adjustsW * (start.x - end.x) / scaleX;
    CGFloat deltaX = anchorPoint.adjustsX * (-1.0 * deltaW);
    CGFloat deltaH = anchorPoint.adjustsH * (end.y - start.y) / scaleY;
    CGFloat deltaY = anchorPoint.adjustsY * (-1.0 * deltaH);
    
    // (3) Calculate the new frame.
    CGFloat newX = self.frame.origin.x + deltaX;
    CGFloat newY = self.frame.origin.y + deltaY;
    CGFloat newWidth = self.bounds.size.width + deltaW;
    CGFloat newHeight = self.bounds.size.height + deltaH;
    
    // (4) If the new frame is too small, cancel the changes.
    if (newWidth < self.minWidth) {
        newWidth = self.minWidth;
        newX = self.frame.origin.x;
    }
    if (newHeight < self.minHeight) {
        newHeight = self.minHeight;
        newY = self.frame.origin.y;
    }
    
    // (5) Ensure the resize won't cause the view to move offscreen.
    if (self.preventsPositionOutsideSuperview) {
        /*
         if (newX < self.superview.bounds.origin.x) {
         // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
         deltaW = self.frame.origin.x - self.superview.bounds.origin.x;
         newWidth = self.frame.size.width + deltaW;
         newX = self.superview.bounds.origin.x;
         }
         if (newX + newWidth > self.superview.bounds.origin.x + self.superview.bounds.size.width) {
         newWidth = self.superview.bounds.size.width - newX;
         }
         if (newY < self.superview.bounds.origin.y) {
         // Calculate how much to grow the height by such that the new Y coordintae will align with the superview.
         deltaH = self.bounds.origin.y - self.superview.bounds.origin.y;
         newHeight = self.frame.size.height + deltaH;
         newY = self.superview.bounds.origin.y;
         }
         if (newY + newHeight > self.superview.bounds.origin.y + self.superview.bounds.size.height) {
         newHeight = self.superview.bounds.size.height - newY;
         }*/
    }
    
    // update the frame
    self.frame = CGRectMake(newX, newY, newWidth, newHeight);
    
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(userResizableViewNewRealFrame:)]) {
        [[self delegate] userResizableViewNewRealFrame:self];
    }
    // resotre the transform
    CGAffineTransform transform     = CGAffineTransformMakeRotation(rotation);
    
    [self setTransform:CGAffineTransformScale(transform, scaleX, scaleY)];
    
    
    touchStart = touchPoint;
}

#pragma mark - Helper functions

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    //[self setAnchorPoint:CGPointMake(0.5, 0.5)];
    
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x, self.center.y + touchPoint.y - touchStart.y);
    
    if (self.preventsPositionOutsideSuperview) {/*
                                                 // Ensure the translation won't cause the view to move offscreen.
                                                 
                                                 CGFloat midPointX = CGRectGetMidX(self.bounds);
                                                 if (newCenter.x > self.superview.bounds.size.width - midPointX) {
                                                 newCenter.x = self.superview.bounds.size.width - midPointX;
                                                 }
                                                 if (newCenter.x < midPointX) {
                                                 newCenter.x = midPointX;
                                                 }
                                                 CGFloat midPointY = CGRectGetMidY(self.bounds);
                                                 if (newCenter.y > self.superview.bounds.size.height - midPointY) {
                                                 newCenter.y = self.superview.bounds.size.height - midPointY;
                                                 }
                                                 if (newCenter.y < midPointY) {
                                                 newCenter.y = midPointY;
                                                 }*/
    }
    self.center = newCenter;
}

- (void)setAnchorPoint:(CGPoint)anchor {
    CGPoint newPoint = CGPointMake(self.bounds.size.width * anchor.x,
                                   self.bounds.size.height * anchor.y);
    CGPoint oldPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x,
                                   self.bounds.size.height * self.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, self.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform);
    
    CGPoint position = self.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    self.layer.position = position;
    self.layer.anchorPoint = anchor;
}



static CGFloat SPDistanceBetweenTwoPoints(CGPoint point1, CGPoint point2) {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
};

typedef struct CGPointSPUserResizableViewAnchorPointPair {
    CGPoint point;
    SPUserResizableViewAnchorPoint anchorPoint;
} CGPointSPUserResizableViewAnchorPointPair;

- (SPUserResizableViewAnchorPoint)anchorPointForTouchLocation:(CGPoint)touchPoint {
    
    
    // (1) Calculate the positions of each of the anchor points.
    CGPointSPUserResizableViewAnchorPointPair upperLeft = { CGPointMake(0.0, 0.0), SPUserResizableViewUpperLeftAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair upperMiddle = { CGPointMake(self.bounds.size.width/2, 0.0), SPUserResizableViewUpperMiddleAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair upperRight = { CGPointMake(self.bounds.size.width, 0.0), SPUserResizableViewUpperRightAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair middleRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height/2), SPUserResizableViewMiddleRightAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair lowerRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height), SPUserResizableViewLowerRightAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair lowerMiddle = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height), SPUserResizableViewLowerMiddleAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair lowerLeft = { CGPointMake(0, self.bounds.size.height), SPUserResizableViewLowerLeftAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair middleLeft = { CGPointMake(0, self.bounds.size.height/2), SPUserResizableViewMiddleLeftAnchorPoint };
    CGPointSPUserResizableViewAnchorPointPair centerPoint = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2), SPUserResizableViewNoResizeAnchorPoint };
    
    // (2) Iterate over each of the anchor points and find the one closest to the user's touch.
    CGPointSPUserResizableViewAnchorPointPair allPoints[9] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight, centerPoint };
    CGFloat smallestDistance = MAXFLOAT; CGPointSPUserResizableViewAnchorPointPair closestPoint = centerPoint;
    for (NSInteger i = 0; i < 9; i++) {
        CGFloat distance = SPDistanceBetweenTwoPoints(touchPoint, allPoints[i].point);
        if (distance < smallestDistance) {
            closestPoint = allPoints[i];
            smallestDistance = distance;
        }
    }
    
    
    // make dragable only small portion of border.
    float check     = ([self resizableInset]+5) * 2;
    
    if (touchPoint.x < check+[self resizableInset] || touchPoint.x >= (self.bounds.size.width-check) || touchPoint.y < check+[self resizableInset] || touchPoint.y >= (self.bounds.size.height-check)) {
        return closestPoint.anchorPoint;
    } else {
        return (SPUserResizableViewAnchorPoint){0,0,0,0};
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isDisabledForTouches:touches]) {
        return;
    }
    
    //m_originalAnchorPoint    = [[self layer] anchorPoint];
    
    // Notify the delegate we've begun our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidBeginEditing:)]) {
        [self.delegate userResizableViewDidBeginEditing:self];
    }
    
    [borderView setHidden:NO];
    UITouch *touch = [touches anyObject];
    
    anchorPoint = [self anchorPointForTouchLocation:[touch locationInView:self]];
    
    // When resizing, all calculations are done in the superview's coordinate space.
    touchStart = [touch locationInView:self.superview];
    if (![self isResizing]) {
        // When translating, all calculations are done in the view's coordinate space.
        touchStart = [touch locationInView:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesFinished:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesFinished:touches];
}

- (void)touchesFinished:(NSSet *)touches {
    if ((didMakeChange || ![self disable]) && self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
    
    didMakeChange   = NO;
    
    if ([self isDisabledForTouches:touches]) {
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // is disabled or there are more touches
    if (![self isDisabledForTouches:touches]) {
        CGPoint point    = [[touches anyObject] locationInView:self.superview];
        
        if ([self isResizing] && [touches count] == 1) {
            if ([self willResize:point]) {
                didMakeChange    = YES;
                [self resizeUsingTouchLocation:point];
            }
        } else if (![self disablePan]){
            didMakeChange    = YES;
            
            [self translateUsingTouchLocation:[[touches anyObject] locationInView:self]];
        }
    }
}

- (void)dealloc {
    [contentView removeFromSuperview];
}

@end
