#
# Be sure to run `pod lib lint UIViewVisibility.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UIViewVisibility'
  s.version          = '0.1.2'
  s.summary          = 'Extension of UIView'

  s.description      = <<-DESC
Extension of UIView such as the visibility property of the view of the Android SDK.
  DESC

  s.homepage         = 'https://github.com/MotokiMiyagi/UIViewVisibility'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Motoki Miyagi' => 'lovingrocknroll@gmail.com' }
  s.source           = { :git => 'https://github.com/MotokiMiyagi/UIViewVisibility.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'UIViewVisibility/Classes/**/*'
end
