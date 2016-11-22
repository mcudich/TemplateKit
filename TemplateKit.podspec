Pod::Spec.new do |s|
  s.name             = "TemplateKit"
  s.version          = "0.1.0"
  s.summary          = "Native UI components in Swift."
  s.description      = "React-inspired framework for building component-based user interfaces in Swift."

  s.homepage         = "https://github.com/mcudich/TemplateKit"
  s.license          = "MIT"
  s.author           = { "Matias Cudich" => "mcudich@gmail.com" }
  s.source           = { :git => "https://github.com/mcudich/TemplateKit.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/mcudich"

  s.ios.deployment_target = "9.3"

  s.source_files = "Source/**/*"

  s.dependency "CSSParser", "~> 1.0"
  s.dependency "CSSLayout", "~> 1.0"
end
