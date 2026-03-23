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
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
