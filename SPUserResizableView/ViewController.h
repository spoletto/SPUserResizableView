//
//  ViewController.h
//  SPUserResizableView
//
//  Created by Stephen Poletto on 12/10/11.
//

#import "SPUserResizableView.h"
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIGestureRecognizerDelegate, SPUserResizableViewDelegate> {
    SPUserResizableView *currentlyEditingView;
    SPUserResizableView *lastEditedView;
    
    /**
     *  Pinch lastScale
     */
    CGFloat lastScale;
    
    /**
     *  Rotate lastRotation
     */
    CGFloat lastRotation;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)handleRotateGesture:(UIRotationGestureRecognizer*)sender;

@end
