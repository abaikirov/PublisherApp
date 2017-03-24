#
#  Be sure to run `pod spec lint PublisherApp.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

s.name         = "PublisherApp"
s.version      = "0.1.4"
s.ios.deployment_target = '8.2'
s.summary      = "Feed for wordpess"

s.license      = { :type => "MIT", :file => "LICENSE" }

s.homepage = "https://github.com/demonotter/PublisherApp"
s.author             = { "Dmitry Zheshinsky" => "demonotter@gmail.com" }
s.source = { :git => "https://github.com/demonotter/PublisherApp.git", :tag => "#{s.version}"}

s.framework = "UIKit"
s.framework = "Foundation"
s.dependency 'AFNetworking'
s.dependency 'DCKeyValueObjectMapping', '~> 1.5'
s.dependency 'DateTools', '~> 1.7.0'
s.dependency 'ReactiveCocoa', '~> 2.5'
s.dependency 'SDWebImage', '~> 3.8.1'
s.dependency 'UIColor-HexString', '~> 1.1.0'
s.dependency 'RegExCategories', '~> 1.0'
s.dependency 'Realm'

# 8
s.source_files = "PublisherApp/Source/*"

# 9
s.resources = "PublisherApp/Assets/*.{png,jpeg,jpg,storyboard,xib}"

end
