#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'fl_amap_map'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/Wayaer/fl_amap.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'email' => 'wayaer@foxmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'AMap3DMap'
  s.dependency 'fl_channel'
  s.static_framework = true
  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

end

