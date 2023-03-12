#
# Be sure to run `pod lib lint SortedDictionary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SortedDictionary'
  s.version          = '0.2.20230312'
  s.summary          = 'Sorted Dictionary'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Sorted Dictionary base on AVL tree, you can sorted by dictionary key or value
                       DESC

  s.homepage         = 'https://github.com/lalawue/SortedDictionary'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lalawue' => 'suchaaa@gmail.com' }
  s.source           = { :git => 'https://github.com/lalawue/SortedDictionary.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SortedDictionary/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SortedDictionary' => ['SortedDictionary/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  spec.swift_version = '5'
end
