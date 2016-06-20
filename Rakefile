require 'bundler/gem_tasks'
require 'rake/clean'

CLEAN.include(
  'pkg',
  'doc',
  'coverage',
  '*.gem'
)

desc 'Run all tests and collect code coverage'
task :cov do
  ENV['SIMPLECOV'] = 'features'
  Rake::Task['default'].invoke
end

require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  t.fork = true
  t.profile = :default
end

task cucumber: :features

require 'rspec/core/rake_task'

desc 'Run RSpec'
RSpec::Core::RakeTask.new do |t|
  t.fail_on_error = false
  t.verbose = true
  t.rspec_opts = '--format RspecJunitFormatter  --out rspec.xml --tag ~wip'
end

task default: [:spec, :features]
