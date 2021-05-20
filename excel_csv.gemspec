Gem::Specification.new do |spec|
  spec.name = 'excel_csv'
  spec.version = '0.0.3'
  spec.authors = ['Marketplacer']
  spec.email = ['it@marketplacer.com']
  spec.summary = 'Read & write CSV that can be used reliably by Microsoft Excel'
  spec.description = ''
  spec.homepage = ''
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'bundler', '>= 2.1.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
