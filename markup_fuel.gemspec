# frozen_string_literal: true

require './lib/markup_fuel/version'

Gem::Specification.new do |s|
  s.name        = 'markup_fuel'
  s.version     = MarkupFuel::VERSION
  s.summary     = 'XML jobs for Burner'

  s.description = <<-DESCRIPTION
    This library adds XML-centric jobs to the Burner library.  Burner does not ship with XML jobs out of the box.
  DESCRIPTION

  s.authors     = ['Matthew Ruggio']
  s.email       = ['mruggio@bluemarblepayroll.com']
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir      = 'exe'
  s.executables = %w[]
  s.homepage    = 'https://github.com/bluemarblepayroll/markup_fuel'
  s.license     = 'MIT'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/bluemarblepayroll/markup_fuel/issues',
    'changelog_uri' => 'https://github.com/bluemarblepayroll/markup_fuel/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/gems/markup_fuel',
    'homepage_uri' => s.homepage,
    'source_code_uri' => s.homepage
  }

  s.required_ruby_version = '>= 2.5'

  s.add_dependency('burner', '~>1.0')
  s.add_dependency('xml-simple', '~>1.1')

  s.add_development_dependency('guard-rspec', '~>4.7')
  s.add_development_dependency('pry', '~>0')
  s.add_development_dependency('rake', '~> 13')
  s.add_development_dependency('rspec', '~> 3.8')
  s.add_development_dependency('rubocop', '~>0.90.0')
  s.add_development_dependency('simplecov', '~>0.18.5')
  s.add_development_dependency('simplecov-console', '~>0.7.0')
end
