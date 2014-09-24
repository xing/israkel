$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'jeweler'
require 'israkel'

Jeweler::Tasks.new do |gem|
  gem.name = 'israkel'
  gem.homepage = 'http://github.com/xing/israkel'
  gem.license = 'MIT'
  gem.summary = %Q{Collection of common rake tasks for the iPhone Simulator.}
  gem.description = %Q{Collection of common rake tasks for the iPhone Simulator like start/stop and some more.}
  gem.email = ['johannes.plunien@xing.com', 'stefan.munz@xing.com']
  gem.authors = ['Johannes Plunien', 'Stefan Munz']
end
Jeweler::RubygemsDotOrgTasks.new

i = ISRakel::Tasks.instance
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

desc 'Allow AddressBook access'
task :allow_addressbook_access do
  i.allow_addressbook_access('com.xing.XING')
end

desc 'Allow GPS access'
task :allow_gps_access do
  i.allow_gps_access('com.xing.XING')
end

desc 'Allow Photo Library access'
task :allow_photos_access do
  i.allow_photos_access('com.xing.XING')
end

desc 'Run the tests'
task :spec do
  sh "rspec spec/"
end
