Pod::Spec.new do |spec|
  spec.name                     = "TokensView"
  spec.version                  = "0.9.0"
  spec.summary                  = "TokensView is a macos framework for tags/token management, like tags in Finder."
  spec.homepage                 = "https://github.com/satroschenko/TokensView"
  spec.license                  = {type: "MIT", file: "LICENSE"}
  spec.author                   = { "Sergey Atroschenko" => "satroschenko@gmail.com" }
  spec.platform                 = :macos
  spec.osx.deployment_target    = "10.14"
  spec.source                   = { :git => "https://github.com/satroschenko/TokensView.git", :tag => "#{spec.version}" }
  spec.swift_versions              = ['5.3', '5.4', '5.5']
  spec.source_files             = "Sources/*.swift"
  spec.resources                = "Sources/*.xcassets"
end
