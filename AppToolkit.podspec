Pod::Spec.new do |s|
  s.name             = "AppToolkit"
  s.version          = "1.0.0"
  s.summary          = "Useful tools you need to launch your app."
  s.description      = <<-DESC
                       We provide tools for launching your app like
                       measuring app installs, capturing light data
                       about how the app is being used, etc.
                       DESC
  s.homepage         = "https://github.com/apptoolkitio/apptoolkit-ios"
  s.license          = 'Apache 2.0'
  s.author           = { "AppToolkit" => "info@apptoolkit.io" }
  s.source           = { :git => "https://github.com/apptoolkitio/apptoolkit-ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/apptoolkitio'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.default_subspec = 'AppToolkit'

  s.subspec 'AppToolkit' do |apptoolkit|
    apptoolkit.source_files = 'AppToolkit/Classes/**/*.{h,m,c}'
    apptoolkit.private_header_files = 'AppToolkit/Classes/ThirdParty/**/*.h'
    apptoolkit.exclude_files = 'AppToolkit/Classes/**/Private/*'
  end

  s.subspec 'Internal' do |internal|
    internal.source_files = 'AppToolkit/Classes/**/*.{h,m,c}'
    internal.private_header_files = 'AppToolkit/Classes/ThirdParty/**/*.h'
    internal.exclude_files = 'AppToolkit/Classes/**/Public/*'
  end

  s.preserve_paths = 'AppToolkit/Scripts/**/*'

  s.libraries = 'z'
end
