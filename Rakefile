$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'jeweler'
require 'israkel'

Jeweler::Tasks.new do |gem|
  gem.name = 'israkel'
  gem.homepage = 'http://github.com/plu/israkel'
  gem.license = 'MIT'
  gem.summary = %Q{Collection of common rake tasks for the iPhone Simulator.}
  gem.description = %Q{Collection of common rake tasks for the iPhone Simulator like start/stop and some more.}
  gem.email = 'plu@pqpq.de'
  gem.authors = ['Johannes Plunien']
end
Jeweler::RubygemsDotOrgTasks.new

i = ISRakel::Tasks.new
desc "Change keyboard preferences"
task :set_keyboard_preferences do
  i.edit_preferences do |p|
    p.merge!({
      :KeyboardAutocapitalization => false,
      :KeyboardAutocorrection     => false,
      :KeyboardCapsLock           => false,
      :KeyboardCheckSpelling      => false,
      :KeyboardPeriodShortcut     => false,
    })
  end
end

desc "Allow GPS access"
task :allow_gps_access do
  i.allow_gps_access("com.plu.FooApp")
end
