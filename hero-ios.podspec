#
# Be sure to run `pod lib lint hero-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'hero-ios'
  s.version          = '1.1.50'
  s.summary          = 'A short description of hero-ios.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://www.hero-mobile.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '刘国平' => 'guoping.liu@dianrong.com' }
  s.source           = { :git => 'https://github.com/hero-node/hero-ios', :tag => s.version.to_s }
  s.social_media_url = 'http://www.hero-mobile.com'

  s.ios.deployment_target = '9.3'

  s.source_files = 'hero-ios/Classes/**/*'

  s.resource_bundles = {
    'hero-ios' => ['hero-ios/Assets/images/*.png']
  }

  s.public_header_files = 'hero-ios/Classes/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.frameworks = 'LocalAuthentication', 'AVFoundation'
  s.dependency 'MJRefresh'
  s.dependency 'UICKeyChainStore'
  s.dependency 'Objective-LevelDB'
  s.dependency 'KTVCocoaHTTPServer'
  s.dependency 'SBJson', '~> 4.0.2'
  s.dependency 'Yaml'
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'CocoaLumberjack'
  s.dependency 'Resolver'
  s.dependency 'Sodium'
  s.ios.vendored_frameworks = 'hero-ios/Frameworks/ethers.framework'
  s.ios.vendored_frameworks = 'hero-ios/Frameworks/lwip.framework'
  s.ios.vendored_frameworks = 'hero-ios/Frameworks/tun2socks.framework'
  s.ios.vendored_frameworks = 'hero-ios/Frameworks/MMDB.framework'
  s.ios.vendored_frameworks = 'hero-ios/Frameworks/CocoaLumberjackSwift.framework'
  s.ios.vendored_frameworks = 'hero-ios/Frameworks/NEKit.framework'
  #s.dependency 'web3swift'
end
