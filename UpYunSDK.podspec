Pod::Spec.new do |s|
  s.name         = "UpYunSDK"
  s.version      = "2.1"
  s.summary      = "SDK for UpYun."

  s.homepage     = "https://github.com/iblacksun/ios-form-sdk"
  
  s.license      = { :type => 'Commercial', :text => 'UpYun All Rights Reserved.' }
  s.author       = { "black sun" => "blacksun1017@gmail.com" }

  s.platform     = :ios, '6.0'

  s.source       = { :git => "https://github.com/iblacksun/ios-form-sdk.git", :tag => "2.1" }

  s.source_files  = 'UpYunSDK2.0/UpYunSDK2.0/**/*.{h,m}'
  s.public_header_files = 'UpYunSDK2.0/UpYunSDK2.0/**/*.{h,m}'
  s.requires_arc = true

  s.dependency 'NSData+MD5Digest'
  s.dependency 'Base64'
  s.dependency 'AFNetworking'
  
end
