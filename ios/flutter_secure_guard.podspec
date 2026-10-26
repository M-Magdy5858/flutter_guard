#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_secure_guard.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_secure_guard'
  s.version          = '0.1.0'
  s.summary          = 'Screen capture protection and device integrity checks for Flutter.'
  s.description      = <<-DESC
Blocks screenshots and screen recording of sensitive content, blurs the app
switcher snapshot, and detects jailbreaks, simulators, debuggers and hooking
frameworks.
                       DESC
  s.homepage         = 'https://github.com/YOUR_GITHUB_USERNAME/flutter_secure_guard'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mahmoud Magdy' => 'mahmoud.magdy@itworx.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_secure_guard/Sources/flutter_secure_guard/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'flutter_secure_guard_privacy' => ['flutter_secure_guard/Sources/flutter_secure_guard/PrivacyInfo.xcprivacy']}
end
