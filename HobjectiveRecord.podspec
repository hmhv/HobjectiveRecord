@version = "0.2.1"

Pod::Spec.new do |s|
  s.name         = "HobjectiveRecord"
  s.version      = @version
  s.summary      = "Lightweight and sexy CoreData Library　for background operation"
  s.homepage     = "https://github.com/hmhv/HobjectiveRecord"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "hmhv" => "admin@hmhv.info" }
  s.source       = { :git => "https://github.com/hmhv/HobjectiveRecord.git", :tag => @version }

  s.source_files = 'HobjectiveRecord/**/*.{h,m}'
  s.framework  = 'CoreData'
  s.requires_arc = true

  s.ios.deployment_target = '6.0'

end
