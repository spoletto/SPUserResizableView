//
//  SPUserResizableView.h
//  SPUserResizableView
//
//  Created by Stephen Poletto on 12/10/11.
//
//  SPUserResizableView is a user-resizable, user-repositionable
//  UIView subclass.

#import <Foundation/Foundation.h>

typedef struct SPUserResizableViewAnchorPoint {
    CGFloat adjustsX;
    CGFloat adjustsY;
    CGFloat adjustsH;
    CGFloat adjustsW;
} SPUserResizableViewAnchorPoint;

@protocol SPUserResizableViewDelegate;
@class SPGripViewBorderView;

@interface SPUserResizableView : UIView {
    SPGripViewBorderView *borderView;
    UIView *__weak contentView;
    CGPoint touchStart;
    CGFloat minWidth;
    CGFloat minHeight;
    
    // Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
    SPUserResizableViewAnchorPoint anchorPoint;
    
    id <SPUserResizableViewDelegate> __weak delegate;
    
    /**
     *  This will ensure that when the resizing is done, it will restore
     *  anchor point.
     */
    CGPoint m_originalAnchorPoint;
}

@property (nonatomic, weak) id <SPUserResizableViewDelegate> delegate;

/**
 *  Will be retained as a subview.
 */
@property (nonatomic, weak) UIView *contentView;

/**
 *  Minimum width to let user resize
 *  @default Default is 48.0 for each.
 */
@property (nonatomic) CGFloat minWidth;
/**
 *  Minimum height that will let user to resize
 */
@property (nonatomic) CGFloat minHeight;

/**
 *  Disables resize of the view
 *  @default NO
 */
@property (nonatomic) BOOL disable;

/**
 *  Disables resize of the view if user use more than 1 finger.
 *  @default NO
 */
@property (nonatomic) BOOL disableOnMultiTouch;
/**
 *  Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
 */
@property (nonatomic) BOOL preventsPositionOutsideSuperview;

/**
 *  Defines if pan is disabled.
 *  @default NO
 */
@property (nonatomic) BOOL disablePan;

/**
 *  Hide editing handles
 */
- (void)hideEditingHandles;
/**
 *  Shows editing handles
 */
- (void)showEditingHandles;

/**
 *  Is currently resizing?
 *
 *  @return BOOL
 */
- (BOOL)isResizing;

@end

@protocol SPUserResizableViewDelegate <NSObject>

@optional

/**
 *  Called when the resizable view receives touchesBegan: and activates the editing handles.
 *
 *  @param userResizableView
 */
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView;

/**
 *  Called when the resizable view receives touchesEnded: or touchesCancelled:
 *
 *  @param userResizableView
 */
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView;

/**
 *  Called when new frame was set.
 *
 *  @param userResizableView
 */
- (void)userResizableViewNewRealFrame:(SPUserResizableView *)userResizableView;;

@end
