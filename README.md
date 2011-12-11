SPUserResizableView
===============

SPUserResizableView is a user-resizable, user-repositionable UIView subclass. It is modeled after the resizable image view from the Pages iOS app. Any UIView can be provided as the content view for the SPUserResizableView. As the view is respositioned and resized, setFrame: will be called on the content view accordingly.