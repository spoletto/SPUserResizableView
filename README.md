SPUserResizableView
===============

SPUserResizableView is a user-resizable, user-repositionable UIView subclass. It is modeled after the resizable image view from the Pages iOS app. Any UIView can be provided as the content view for the SPUserResizableView. As the view is respositioned and resized, setFrame: will be called on the content view accordingly.

Screenshot
----
![SPUserResizableView](http://i.imgur.com/krBjw.png)

How To Use It
-------------

### Installation

Include SPUserResizableView.h and SPUserResizableView.m in your project.

### Setting up the SPUserResizableView

You'll need to #import the SPUserResizableView.h header and construct a new instance of SPUserResizableView. Then, set the contentView on the SPUserResizableView to the view you'd like the user to interact with.

``` objective-c
#import "SPUserResizableView.h"

...
    
- (void)viewDidLoad {
    CGRect frame = CGRectMake(50, 50, 200, 150);
    SPUserResizableView *userResizableView = [[SPUserResizableView alloc] initWithFrame:frame];
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    [contentView setBackgroundColor:[UIColor redColor]];
    userResizableView.contentView = contentView;
    [self.view addSubview:userResizableView];
    [contentView release]; 
    [userResizableView release];
}
```

If you'd like to receive callbacks when the SPUserResizableView receives touchBegan:, touchesEnded: and touchesCancelled: messages, set the delegate on the SPUserResizableView accordingly. 

``` objective-c
userResizableView.delegate = self;
```

Then implement the following delegate methods.

``` objective-c
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
- (void)userResizableViewNewRealFrame:(SPUserResizableView *)userResizableView;
```

By default, SPUserResizableView will show the editing handles (as seen in the screenshot above) whenever it receives a touch event. The editing handles will remain visible even after the userResizableViewDidEndEditing: message is sent. This is to provide visual feedback to the user that the view is indeed moveable and resizable. If you'd like to dismiss the editing handles, you must explicitly call -hideEditingHandles.

The SPUserResizableView is customizable using the following properties:

``` objective-c
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
 *  Defines the insent of the content.
 *  Larger == better detection
 */
@property (nonatomic) float resizableInset;
/**
 *  Interactive border size
 */
@property (nonatomic) float interactiveBorderSize;
```
	
For an example of how to use SPUserResizableView, please see the included example project.

