Pod::Spec.new do |s|

  s.name         = "FontAwesomeForMacOS"
  s.version      = "1.0"
  s.summary      = "Use Font Awesome in your macOS Swift projects"
  s.homepage     = "http://EXAMPLE/FontAwesomeForMacOS"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Da Costa Faro Rémy" => "remy@dacostafaro.com" }
  s.social_media_url   = "http://twitter.com/asmartcode"

  s.platform     = :osx, "10.9"

  s.source       = { :git => "https://github.com/RemyDCF/FontAwesomeForMacOS.git", :tag => "#{s.version}" }

  s.source_files = 'FontAwesomeForMacOS/*.{swift}'
  s.resource_bundle = { 'FontAwesomeForMacOS.swift' => 'FontAwesomeForMacOS/*.otf' }
  s.frameworks = 'Cocoa', 'CoreText'
end
