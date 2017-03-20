Pod::Spec.new do |s|
  s.name             = 'LivePaperSDK'
  s.version          = '2.0.0'
  s.summary          = 'Link Developer iOS library'
  s.description      = 'Provides an interface to the "Link" service by HP for creating watermarked images, QR codes, and mobile-friendly shortened URLs.'
  s.homepage         = 'https://mylinks.linkcreationstudio.com/developer/libraries/ios/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'a1cf64a6c93c5292335a0e92ef14cae19862967c' => 'alejandro.mendez@hp.com' }
  s.source           = { :git => 'https://github.com/IPGPTP/live_paper_sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'LivePaperSDK/LivePaperSDK/Classes/**/*'
  s.dependency 'HPLinkUtils'
end
