Pod::Spec.new do |s|
  s.name         = "SPUserResizableView"
  s.version      = "1.0.0"
  s.summary      = "SPUserResizableView is a user-resizable, user-repositionable UIView subclass built for iOS."
  s.homepage     = "https://github.com/spoletto/SPUserResizableView"
  s.license      = 'MIT'
  s.author       = { "Stephen Poletto" => "private@example.com" }
  s.source       = { :git => "https://github.com/spoletto/SPUserResizableView.git", :tag => "1.0.0" }
  s.platform     = :ios, '5.0'
  s.source_files = 'SPUserResizableView/SPUserResizableView.{h,m}'
  s.requires_arc = false
end
