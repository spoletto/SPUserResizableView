//
//  ViewController.m
//  SPInteractiveLabel
//
//  Created by Stephen Poletto on 12/10/11.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:appFrame];
    self.view.backgroundColor = [UIColor greenColor];
    
    // (1) Create a user resizable view with a simple red background content view.
    CGRect gripFrame = CGRectMake(50, 50, 200, 150);
    SPUserResizableView *userResizableView = [[SPUserResizableView alloc] initWithFrame:gripFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:gripFrame];
    [contentView setBackgroundColor:[UIColor redColor]];
    userResizableView.contentView = contentView;
    userResizableView.delegate = self;
    [userResizableView showEditingHandles];
    currentlyEditingView = userResizableView;
    lastEditedView = userResizableView;
    [self.view addSubview:userResizableView];
    [contentView release]; [userResizableView release];
    
    // (2) Create a second resizable view with a UIImageView as the content.
    CGRect imageFrame = CGRectMake(50, 200, 200, 200);
    SPUserResizableView *imageResizableView = [[SPUserResizableView alloc] initWithFrame:imageFrame];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"milky_way.jpg"]];
    imageResizableView.contentView = imageView;
    imageResizableView.delegate = self;
    [self.view addSubview:imageResizableView];
    [imageView release]; [imageResizableView release];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditingHandles)];
    [gestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
}

- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView {
    [currentlyEditingView hideEditingHandles];
    currentlyEditingView = userResizableView;
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView {
    lastEditedView = userResizableView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([currentlyEditingView hitTest:[touch locationInView:currentlyEditingView] withEvent:nil]) {
        return NO;
    }
    return YES;
}

- (void)hideEditingHandles {
    // We only want the gesture recognizer to end the editing session on the last
    // edited view. We wouldn't want to dismiss an editing session in progress.
    [lastEditedView hideEditingHandles];
}

@end
