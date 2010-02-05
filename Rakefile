require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "firewall-agent"
    gem.summary = %Q{Firewall Agent is a utility to simplify firewall configuration}
    gem.description = %Q{Firewall Agent is a utility to simplify firewall configuration for clouds and clusters, especially when hosted with 3rd party VPS services.}
    gem.email = "maxmpz@gmail.com"
    gem.homepage = "http://github.com/powcloud/firewall-agent"
    gem.authors = ["Darren Rush", "Max M. Petrov"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.files =  FileList["[A-Z_.]*", "{bin,lib,test}/**/*", 'lib/jeweler/templates/.gitignore']

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.add_dependency('activesupport', '>= 2.3.4')
    gem.add_dependency('eventmachine', '>= 0.12.10')
    gem.add_dependency('log4r', '>= 1.1.2')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "firewall-agent #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
