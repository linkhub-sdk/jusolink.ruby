Gem::Specification.new do |s|
  s.name        = 'jusolink'
  s.version     = '1.0.0'
  s.date        = '2017-02-08'
  s.summary     = 'Jusolink API SDK'
  s.description = 'Jusolink API SDK'
  s.authors     = ["Linkhub Dev"]
  s.email       = 'code@linkhub.co.kr'
  s.files       = ["lib/jusolink.rb"]
  s.license     = 'APACHE LICENSE VERSION 2.0'
  s.homepage    = 'https://github.com/linkhub-sdk/jusolink.ruby'
  s.required_ruby_version = '>= 2.0.0'
  s.add_runtime_dependency 'linkhub', '1.0.1'
  s.add_dependency 'minitest', '4.7.5'
end
