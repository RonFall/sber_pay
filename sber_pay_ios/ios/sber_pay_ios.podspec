Pod::Spec.new do |s|
  s.name             = 'sber_pay_ios'
  s.version          = '1.0.0'
  s.summary          = 'Plugin for native payment service SberPay'
  s.description      = <<-DESC
SberPay plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.preserve_paths = 'SPaySdk.xcframework/**/*'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework SPaySdk' }
  s.vendored_frameworks = 'SPaySdk.xcframework'
end
