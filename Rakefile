$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'israkel'

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
  i.current_device.allow_addressbook_access('com.xing.XING')
end

desc 'Allow GPS access'
task :allow_gps_access do
  i.current_device.allow_gps_access('com.xing.XING')
end

desc 'Allow Photo Library access'
task :allow_photos_access do
  i.current_device.allow_photos_access('com.xing.XING')
end

desc 'Run the tests'
task :spec do
  sh "rspec spec/"
end
