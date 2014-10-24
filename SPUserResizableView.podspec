Pod::Spec.new do |s|
  s.name         = 'SPUserResizableView+Pion'
  s.version      = '0.5'
  s.license      =  'MIT'
  s.homepage     = 'https://github.com/pionl/SPUserResizableView'
  s.authors      =  'Stephen Poletto'
  s.summary      = 'A forked (originaly from STephen Poletto) SPUserResizableView is a user-resizable, user-repositionable UIView subclass. It is modeled after the resizable image view from the Pages iOS app. '

# Source Info
  s.platform     =  :ios, '5.0'
  s.source       =  {:git => 'https://github.com/pionl/SPUserResizableView', :tag => '0.5'}
  s.source_files = 'SPUserResizableView.{h,m}'
  s.requires_arc = true
  
# Pod Dependencies

end