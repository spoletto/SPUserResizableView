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
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView;
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView;
```

By default, SPUserResizableView will show the editing handles (as seen in the screenshot above) whenever it receives a touch event. The editing handles will remain visible even after the userResizableViewDidEndEditing: message is sent. This is to provide visual feedback to the user that the view is indeed moveable and resizable. If you'd like to dismiss the editing handles, you must explicitly call -hideEditingHandles.

The SPUserResizableView is customizable using the following properties:

``` objective-c
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) BOOL preventsPositionOutsideSuperview;
```
	
For an example of how to use SPUserResizableView, please see the included example project.

