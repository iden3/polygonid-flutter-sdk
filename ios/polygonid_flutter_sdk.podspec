#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run 'pod lib lint polygonid_flutter_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'polygonid_flutter_sdk'
  s.version          = '2.4.0'
  s.summary          = 'Flutter plugin for PolygonID SDK'
  s.description      = <<-DESC
PolygonID SDK flutter plugin project.
                       DESC
  s.homepage         = 'https://polygon.technology/polygon-id'
  s.license          = { :file => '../LICENSE-MIT' }
  s.author           = { 'Polygon ID' => 'raulj@polygon.technology' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.vendored_libraries = "./*.a"
  s.dependency 'Flutter'
  s.dependency 'CryptoSwift'
  s.platform = :ios, '9.0'
  s.libraries = ["c++", "z"]
  # s.ios.deployment_target = '9.0'
  s.preserve_paths = [
    'Frameworks/libpolygonid.xcframework/**/*',
  ]
  s.ios.vendored_frameworks = [
    'Frameworks/libpolygonid.xcframework',
#     'Frameworks/Core.xcframework'
  ]
  # Flutter.framework does not contain a i386 nor arm64 slice.
  s.pod_target_xcconfig = {
    "OTHER_LDFLAGS" => "-lc++ -lz",
    "DEFINES_MODULE" => "YES"
  }
  s.swift_version = '5.0'
end
