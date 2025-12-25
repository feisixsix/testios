Pod::Spec.new do |s|
  s.name                  = 'Flutter'
  s.version               = '1.0.0'
  s.summary               = 'High-performance, high-fidelity mobile apps.'
  s.description           = <<-DESC
Flutter provides an easy and productive way to build and deploy high-performance mobile apps on both iOS and Android.
                         DESC
  s.homepage              = 'https://flutter.io'
  s.license               = { :type => 'MIT' }
  s.author                = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source                = { :git => 'https://github.com/flutter/engine', :tag => 'v1.0.0' }
  s.platform              = :ios, '14.0'
  s.vendored_frameworks   = 'Flutter.xcframework'
end
