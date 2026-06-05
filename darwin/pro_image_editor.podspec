#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pro_image_editor.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pro_image_editor'
  s.version          = '12.0.8'
  s.summary          = 'A Flutter image editor plugin.'
  s.description      = <<-DESC
A Flutter image editor: Seamlessly enhance your images with user-friendly editing features.
                       DESC
  s.homepage         = 'https://github.com/hm21/pro_image_editor'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'hm21' => 'info@waio.ch' }
  s.source           = { :path => '.' }
  s.source_files     = 'pro_image_editor/Sources/pro_image_editor/**/*'
  s.swift_version    = '5.0'
  s.osx.frameworks   = 'FlutterMacOS'

  s.ios.deployment_target = '12.0'
  s.ios.dependency 'Flutter'
  s.ios.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' 
  }

  s.osx.deployment_target = '10.14'
  s.osx.dependency 'FlutterMacOS'
  s.osx.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
end