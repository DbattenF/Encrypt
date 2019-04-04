Pod::Spec.new do |s|
  #1.
  s.name         = "Encrypt"
  #2.
  s.version      = "0.0.2"
  #3.
  s.summary      = "A short description of Encrypt."
  #4.
  s.homepage     = "http://EXAMPLE/Encrypt"
  #5.
  s.license      = "MIT"
  #6.
  s.author       = "Santiago Faverio"
  #7.
  s.source       = { :git => "https://github.com/DbattenF/Encrypt.git", :branch => "master", :tag => "#{s.version.to_s}" }
  #8.
  s.source_files = "Encrypt", "Encrypt/**/*.{h,m,swift}"
  
end
