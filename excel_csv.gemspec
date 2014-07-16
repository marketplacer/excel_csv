# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "excel_csv"
  spec.version       = "0.0.2"
  spec.authors       = ["The Exchange Group"]
  spec.email         = ["hello@teg.io"]
  spec.summary       = %q{Read & write CSV that can be used reliably by Microsoft Excel}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activesupport"

end
