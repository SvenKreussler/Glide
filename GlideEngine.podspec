Pod::Spec.new do |s|
  s.name = 'GlideEngine'
  s.version = '1.0.4'
  s.license = 'MIT'
  s.summary = 'Game engine for making 2d games on iOS, macOS and tvOS'
  s.homepage = 'https://github.com/cocoatoucher/Glide'
  s.authors = { 'cocoatoucher' => 'cocoatoucher@posteo.se' }
  s.swift_version = '5.0'
  
  # Per-arch flags
  s.osx.xcconfig = { 'OTHER_CFLAGS' => '-fno-objc-arc -w -Xanalyzer -analyzer-disable-all-checks' }
  
  s.ios.deployment_target = '11.4'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '12.0'
  
  s.source = { :git => 'https://github.com/cocoatoucher/Glide.git', :tag => s.version }
  s.source_files = "Shared/**/*.swift"
  s.ios.source_files = ["Glide_iOS/*.swift"]
  s.osx.source_files = ["Glide_macOS/**/*.swift"]
  
  s.frameworks  = "Foundation", "CoreGraphics", "SpriteKit"
end
